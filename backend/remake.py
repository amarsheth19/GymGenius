import cv2
import os
import logging
from fastapi import FastAPI, File, UploadFile, HTTPException
from io import BytesIO
from tempfile import NamedTemporaryFile

app = FastAPI()

logging.basicConfig(level=logging.INFO)

@app.post("/process_video")
async def process_video(file: UploadFile = File(...)):
    try:
        temp_file = NamedTemporaryFile(delete=False, suffix=".mp4")
        with open(temp_file.name, "wb") as f:
            f.write(await file.read())
        input_video_path = temp_file.name
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error saving video: {str(e)}")

    output_video_path = "processed_output.mp4"
    
    try:
        video_capture = cv2.VideoCapture(input_video_path)
        if not video_capture.isOpened():
            raise HTTPException(status_code=400, detail="Could not open the video file.")
        
        width = int(video_capture.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = video_capture.get(cv2.CAP_PROP_FPS)
        
        fourcc = cv2.VideoWriter_fourcc(*'avc1')
        output_video = cv2.VideoWriter(output_video_path, fourcc, fps, (width, height))
        
        frame_count = 0
        
        while True:
            ret, frame = video_capture.read()
            if not ret:
                break
            processed_frame = process_frame(frame)
            output_video.write(processed_frame)
            frame_count += 1
            logging.info(f"Processing frame {frame_count}")
        
        video_capture.release()
        output_video.release()

        return {"message": f"Processed video with {frame_count} frames."}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing video: {str(e)}")
    finally:
        os.remove(input_video_path)


def process_frame(frame):
    """Process individual frames (e.g., convert to grayscale)."""
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    return cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)
