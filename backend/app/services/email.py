from __future__ import annotations

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from ..config import settings


def send_recovery_email(to_email: str, code: str, nombre: str) -> bool:
    if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
        print(f"[EMAIL-DEBUG] Código de recuperación para {to_email}: {code}")
        return True

    msg = MIMEMultipart("alternative")
    msg["Subject"] = "Brain Test — Código de recuperación"
    msg["From"] = settings.SMTP_FROM or settings.SMTP_USER
    msg["To"] = to_email

    text = (
        f"Hola {nombre},\n\n"
        f"Tu código de recuperación es: {code}\n\n"
        "Este código expira en 10 minutos.\n"
        "Si no solicitaste este cambio, ignora este correo.\n\n"
        "— Brain Test, ESCOM-IPN"
    )

    html = f"""\
<html>
<body style="font-family:Arial,sans-serif;background:#0a0a0a;color:#fff;padding:32px;">
  <div style="max-width:480px;margin:0 auto;background:#1a1a1a;border-radius:16px;padding:32px;">
    <h2 style="color:#57078E;margin:0 0 16px;">Brain Test</h2>
    <p>Hola <strong>{nombre}</strong>,</p>
    <p>Tu código de recuperación es:</p>
    <div style="text-align:center;margin:24px 0;">
      <span style="font-size:32px;letter-spacing:8px;font-weight:bold;
                    background:linear-gradient(135deg,#350268,#57078E);
                    color:#fff;padding:16px 32px;border-radius:12px;">
        {code}
      </span>
    </div>
    <p style="color:#999;font-size:13px;">
      Este código expira en <strong>10 minutos</strong>.<br>
      Si no solicitaste este cambio, ignora este correo.
    </p>
    <hr style="border:none;border-top:1px solid #333;margin:24px 0;">
    <p style="color:#666;font-size:11px;text-align:center;">
      Brain Test — TT 2026-B141, ESCOM-IPN
    </p>
  </div>
</body>
</html>"""

    msg.attach(MIMEText(text, "plain"))
    msg.attach(MIMEText(html, "html"))

    try:
        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10) as server:
            server.starttls()
            server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
            server.sendmail(msg["From"], [to_email], msg.as_string())
        return True
    except Exception as e:
        print(f"[EMAIL-ERROR] {e}")
        return False
