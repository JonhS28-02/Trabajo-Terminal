from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440

    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM: str = ""

    # Orígenes web permitidos, separados por coma. La app móvil no usa CORS.
    CORS_ORIGINS: str = "*"

    # Registro de modelos. Sin cadena de conexión se usan los archivos incluidos en app/ml/models.
    MODEL_VERSION: str = "v01"
    MODELS_CONTAINER: str = "modelos"
    AZURE_STORAGE_CONNECTION_STRING: str = ""

    model_config = {"env_file": ".env", "extra": "ignore"}


settings = Settings()
