from fastapi import FastAPI

app = FastAPI(
    title="Roxmontech API",
    version="1.0.0",
)

@app.get("/")
def home():
    return {
        "message": "Roxmontech API funcionando correctamente"
    }