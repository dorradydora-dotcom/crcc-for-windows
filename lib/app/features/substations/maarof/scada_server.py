"""
خادم وسيط لاستقبال وتوزيع بيانات محطة معروف (MAAROUF SCADA Bridge API)
=======================================================================
المتطلبات:
    pip install fastapi uvicorn pydantic

طريقة التشغيل:
    python scada_server.py
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Any, Dict
import uvicorn
from datetime import datetime

app = FastAPI(title="MAAROUF SCADA Telemetry Bridge", version="1.0.0")

# تفعيل الـ CORS لتطبيق فلاتر
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# هيكل بيانات الإشارة
class TelemetryItem(BaseModel):
    description: str
    value: Any
    gid: Optional[int] = None
    address: Optional[int] = None
    group_heading: Optional[str] = "Measrmt"  # Measrmt أو SPS

class TelemetryBatch(BaseModel):
    timestamp: Optional[str] = None
    data: List[TelemetryItem]

# مخزن البيانات اللحظية
live_telemetry_cache: Dict[str, Dict[str, Any]] = {}

@app.get("/")
def root():
    return {
        "status": "running",
        "substation": "MAAROUF",
        "cached_signals": len(live_telemetry_cache),
        "docs_url": "/docs"
    }

# 1. الرابط الذي يرسل إليه مهندس الاتصالات البيانات (POST)
@app.post("/api/v1/telemetry")
async def receive_telemetry_batch(payload: TelemetryBatch):
    now = datetime.now().isoformat()
    for item in payload.data:
        live_telemetry_cache[item.description] = {
            "value": item.value,
            "address": item.address,
            "type": item.group_heading,
            "gid": item.gid,
            "last_updated": now
        }
    print(f"[{now}] Received {len(payload.data)} telemetry items from SCADA Gateway.")
    return {"status": "success", "received": len(payload.data)}

# 2. استقبال بيانات غير مقيدة (Raw JSON Fallback)
@app.post("/api/v1/telemetry/raw")
async def receive_raw_telemetry(request: Request):
    raw_data = await request.json()
    print("Received Raw Data:", raw_data)
    return {"status": "ok", "data_received": raw_data}

# 3. الرابط الذي يقرأ منه تطبيق فلاتر (GET)
@app.get("/api/v1/telemetry/live")
async def get_live_telemetry():
    return live_telemetry_cache

# 4. محاكاة بيانات وهمية للاختبار (Mock Data Generator)
@app.post("/api/v1/telemetry/mock")
async def generate_mock_data():
    now = datetime.now().isoformat()
    mock_signals = [
        {"description": "[PCS-9710-TU1]MAAROUF_AZBAKIA_CB_52", "value": 1, "group_heading": "SPS"},
        {"description": "[PCS-9710-TU1]MAAROUF_SAYEDA1_CB_52", "value": 1, "group_heading": "SPS"},
        {"description": "[PCS-9710-TU1]MAAROUF_NSABT3_CB_52", "value": 0, "group_heading": "SPS"},
        {"description": "[PCS-9710-TU1]MAAROUF_AZBAKIA_I_PHASE_S_CURRENT", "value": 18.5, "group_heading": "Measrmt"},
        {"description": "[PCS-9710-TU1]MAAROUF_SAYEDA1_I_PHASE_S_CURRENT", "value": 125.4, "group_heading": "Measrmt"},
    ]
    for item in mock_signals:
        live_telemetry_cache[item["description"]] = {
            "value": item["value"],
            "type": item["group_heading"],
            "last_updated": now
        }
    return {"status": "mock_generated", "count": len(mock_signals)}

if __name__ == "__main__":
    print("🚀 Starting MAAROUF SCADA Bridge Server on http://0.0.0.0:8000")
    print("📖 Swagger UI Documentation: http://127.0.0.1:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)
