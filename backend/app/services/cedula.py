from __future__ import annotations

import asyncio
import logging

from playwright.async_api import async_playwright, Browser

from ..schemas.auth import CedulaValidationResponse

_SEP_URL = "https://cedulaprofesional.sep.gob.mx"
_log = logging.getLogger(__name__)

_VALID_PROFESSIONS = {
    "médico", "medico", "medicina", "doctor", "doctora",
    "psicólogo", "psicologo", "psicología", "psicologia",
    "psiquiatra", "psiquiatría", "psiquiatria",
    "neurología", "neurologia", "neurólogo", "neurologo",
    "geriatra", "geriatría", "geriatria",
    "gerontología", "gerontologia",
    "enfermería", "enfermeria",
}

_browser: Browser | None = None
_browser_lock = asyncio.Lock()


async def _get_browser() -> Browser:
    global _browser
    async with _browser_lock:
        if _browser is None or not _browser.is_connected():
            pw = await async_playwright().start()
            _browser = await pw.chromium.launch(headless=True)
        return _browser


async def _scrape_cedula(cedula: str) -> list[dict]:
    browser = await _get_browser()
    page = await browser.new_page()
    try:
        await page.goto(_SEP_URL, wait_until="networkidle", timeout=20000)

        # Close the modal if present
        close_btn = page.locator("button:has-text('×')")
        if await close_btn.count() > 0:
            await close_btn.first.click()
            await page.wait_for_timeout(500)

        # Switch to "Número de cédula" tab
        await page.click("text=Número de cédula")
        await page.wait_for_timeout(500)

        # Fill the cedula number
        cedula_input = page.locator("input[placeholder='Cédula']")
        await cedula_input.fill(cedula)

        # Click search
        await page.click("text=Buscar")

        # Wait for results or "no results" message
        try:
            await page.wait_for_selector(
                "table tbody tr, .alert, .no-results",
                timeout=10000,
            )
        except Exception:
            pass

        await page.wait_for_timeout(1500)

        # Check if results table exists
        rows = page.locator("table tbody tr")
        count = await rows.count()

        if count == 0:
            return []

        results = []
        for i in range(count):
            row = rows.nth(i)
            cells = row.locator("td")
            cell_count = await cells.count()
            if cell_count >= 7:
                results.append({
                    "cedula": (await cells.nth(0).inner_text()).strip(),
                    "nombre": (await cells.nth(1).inner_text()).strip(),
                    "primerApellido": (await cells.nth(2).inner_text()).strip(),
                    "segundoApellido": (await cells.nth(3).inner_text()).strip(),
                    "genero": (await cells.nth(4).inner_text()).strip(),
                    "institucion": (await cells.nth(5).inner_text()).strip(),
                    "profesion": (await cells.nth(6).inner_text()).strip(),
                })
        return results
    finally:
        await page.close()


async def validate_cedula(cedula: str) -> CedulaValidationResponse:
    try:
        results = await _scrape_cedula(cedula)
    except Exception as exc:
        _log.error("SEP cedula error: %s: %s", type(exc).__name__, exc)
        return CedulaValidationResponse(
            valid=False,
            message="No se pudo conectar con el servicio de validación "
                    "de cédulas de la SEP. Intente más tarde.",
        )

    if not results:
        return CedulaValidationResponse(
            valid=False,
            message="Cédula profesional no encontrada en el registro de la SEP.",
        )

    record = results[0]
    profesion = (record.get("profesion", "") or "").lower()
    institucion = record.get("institucion", "") or ""
    nombre = " ".join(
        part for part in [
            record.get("nombre", ""),
            record.get("primerApellido", ""),
            record.get("segundoApellido", ""),
        ] if part
    )

    is_health = any(prof in profesion for prof in _VALID_PROFESSIONS)
    if not is_health:
        return CedulaValidationResponse(
            valid=False,
            nombre=nombre,
            especialidad=record.get("profesion", ""),
            institucion=institucion,
            message=f"La cédula corresponde a '{record.get('profesion', '')}', "
                    "que no es una profesión de salud válida para este sistema.",
        )

    return CedulaValidationResponse(
        valid=True,
        nombre=nombre,
        especialidad=record.get("profesion", ""),
        institucion=institucion,
    )
