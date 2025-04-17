import cv2
import os
from fastapi import FastAPI

app = FastAPI()

@app.post("/process_video")
def process_video():
    input_video_path = "output.mp4"  # The input video file
    output_video_path = "processed_output.mp4"  # The output video file

    video_capture = cv2.VideoCapture(input_video_path)
    
    if not video_capture.isOpened():
        return {"Could not open the video file."}
    
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
        print(f"Processing frame {frame_count}")

    video_capture.release()
    output_video.release()

    return {"message": f"Processed video with {frame_count} frames."}


def process_frame(frame):
    # test to do grayscale. Will change for model to mofidy frames
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    return cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)


process_video()