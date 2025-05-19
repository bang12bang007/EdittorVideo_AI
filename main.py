import warnings
warnings.filterwarnings("ignore")
import os
import sys
sys.path.append(os.path.abspath("GFPGAN"))
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
import os
import cv2
import numpy as np
import torch
from PIL import Image
from io import BytesIO
from gfpgan import GFPGANer, GFPGANv1Clean
from fastapi.middleware.cors import CORSMiddleware
import subprocess
import uuid 
import time

# ========== KHỞI TẠO FASTAPI ==========
app = FastAPI(title="GFPGAN API (Image + Video + Fine-tuned)")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Cho phép frontend truy cập
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========== LOAD GFPGAN DEFAULT ==========
model_path = "GFPGAN/experiments/pretrained_models/GFPGANv1.4.pth"

restorer = GFPGANer(
    model_path=model_path,
    upscale=2,
    arch="clean",
    channel_multiplier=2,
    bg_upsampler=None
)

# ========== LOAD FINE-TUNED MODEL ==========
device = "cuda" if torch.cuda.is_available() else "cpu"

def load_finetuned_model():
    model = GFPGANv1Clean(
        out_size=512,
        num_style_feat=512,
        channel_multiplier=2,
        narrow=1,
        sft_half=True
    ).to(device)

    ckpt = torch.load("GFPGAN/experiments/pretrained_models/finetuned_ckpt_ep3.pth", map_location=device)
    model.load_state_dict(ckpt["params"], strict=True)
    model.eval()
    
    # Create GFPGANer with dummy checkpoint but use our fine-tuned model
    finetuned_restorer = GFPGANer(
        model_path=model_path,  # still need to provide a path but won't be used
        upscale=1,
        arch="clean",
        channel_multiplier=2,
        bg_upsampler=None,
        device=device
    )
    finetuned_restorer.gfpgan = model
    return finetuned_restorer

finetuned_restorer = load_finetuned_model()

# ========== API: Phục hồi ảnh với model mặc định ==========
@app.post("/restore")
async def restore_image(file: UploadFile = File(...)):
    start_time = time.time()

    contents = await file.read()
    image = Image.open(BytesIO(contents)).convert("RGB")
    image = np.array(image)

    _, _, restored_image = restorer.enhance(
        image,
        has_aligned=False,
        only_center_face=True,
        paste_back=True
    )

    output_path = f"restored_image_{uuid.uuid4().hex}.jpg"
    Image.fromarray(restored_image).save(output_path)

    duration = time.time() - start_time
    print(f"✅ [RESTORE] Xử lý ảnh mất {duration:.2f} giây")

    return FileResponse(output_path, media_type="image/jpeg")

# ========== API: Phục hồi ảnh với model fine-tuned ==========
@app.post("/fine-tune")
async def restore_with_finetuned(file: UploadFile = File(...)):
    start_time = time.time()

    contents = await file.read()
    image = Image.open(BytesIO(contents)).convert("RGB")
    image = np.array(image)

    _, _, restored_image = finetuned_restorer.enhance(
        image,
        has_aligned=False,
        only_center_face=True,
        paste_back=True
    )

    output_path = f"finetuned_restored_{uuid.uuid4().hex}.jpg"
    Image.fromarray(restored_image).save(output_path)

    duration = time.time() - start_time
    print(f"✅ [FINE-TUNED] Xử lý ảnh mất {duration:.2f} giây")

    return FileResponse(output_path, media_type="image/jpeg")

# ========== API: Phục hồi video với model mặc định ==========
@app.post("/enhance-video/")
async def enhance_video(file: UploadFile = File(...)):
    start_time = time.time()

    input_name = f"temp_{uuid.uuid4().hex}.mp4"
    with open(input_name, "wb") as f:
        f.write(await file.read())

    cap = cv2.VideoCapture(input_name)
    if not cap.isOpened():
        return {"error": "❌ Không mở được video."}

    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    temp_avi = input_name.replace(".mp4", "_enhanced.avi")
    fourcc = cv2.VideoWriter_fourcc(*'MJPG')
    out = cv2.VideoWriter(temp_avi, fourcc, fps, (frame_w, frame_h))

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        try:
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            _, _, restored = restorer.enhance(
                rgb,
                has_aligned=False,
                only_center_face=True,
                paste_back=True
            )
            if isinstance(restored, list):
                restored = restored[0]

            bgr = cv2.cvtColor(restored, cv2.COLOR_RGB2BGR)
            if bgr.shape[:2] != (frame_h, frame_w):
                bgr = cv2.resize(bgr, (frame_w, frame_h))
        except Exception as e:
            print(f"⚠️ Lỗi frame: {e}")
            bgr = frame

        out.write(bgr)

    cap.release()
    out.release()

    final_output = input_name.replace(".mp4", "_final.mp4")
    subprocess.run([
        "ffmpeg", "-y", "-i", temp_avi,
        "-c:v", "libx264", "-preset", "fast", "-crf", "23",
        "-movflags", "+faststart",
        final_output
    ])

    os.remove(input_name)
    os.remove(temp_avi)

    duration = time.time() - start_time
    print(f"✅ [VIDEO] Xử lý video mất {duration:.2f} giây")

    return FileResponse(final_output, media_type="video/mp4", filename="enhanced_video.mp4")

# ========== API: Phục hồi video với model fine-tuned ==========
@app.post("/fine-tune-video/")
async def enhance_video_with_finetuned(file: UploadFile = File(...)):
    start_time = time.time()

    input_name = f"temp_{uuid.uuid4().hex}.mp4"
    with open(input_name, "wb") as f:
        f.write(await file.read())

    cap = cv2.VideoCapture(input_name)
    if not cap.isOpened():
        return {"error": "❌ Không mở được video."}

    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    temp_avi = input_name.replace(".mp4", "_finetuned_enhanced.avi")
    fourcc = cv2.VideoWriter_fourcc(*'MJPG')
    out = cv2.VideoWriter(temp_avi, fourcc, fps, (frame_w, frame_h))

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        try:
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            _, _, restored = finetuned_restorer.enhance(
                rgb,
                has_aligned=False,
                only_center_face=True,
                paste_back=True
            )
            if isinstance(restored, list):
                restored = restored[0]

            bgr = cv2.cvtColor(restored, cv2.COLOR_RGB2BGR)
            if bgr.shape[:2] != (frame_h, frame_w):
                bgr = cv2.resize(bgr, (frame_w, frame_h))
        except Exception as e:
            print(f"⚠️ Lỗi frame (fine-tuned): {e}")
            bgr = frame

        out.write(bgr)

    cap.release()
    out.release()

    final_output = input_name.replace(".mp4", "_finetuned_final.mp4")
    subprocess.run([
        "ffmpeg", "-y", "-i", temp_avi,
        "-c:v", "libx264", "-preset", "fast", "-crf", "23",
        "-movflags", "+faststart",
        final_output
    ])

    os.remove(input_name)
    os.remove(temp_avi)

    duration = time.time() - start_time
    print(f"✅ [FINE-TUNED VIDEO] Xử lý video mất {duration:.2f} giây")

    return FileResponse(final_output, media_type="video/mp4", filename="finetuned_enhanced_video.mp4")

# uvicorn main:app --host 0.0.0.0 --port 8000 
# uvicorn main:app --host 0.0.0.0 --port 8000 -- hot reload  