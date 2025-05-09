from cvzone.PoseModule import PoseDetector
import cv2
import numpy as np
import firebase_admin
from firebase_admin import credentials, storage




# def grabAndGo() {
#     cred = credentials.Certificacate("specific.json")
#     firebase_admin.initialize_app(cred,{'storageBucket': 'gym-genius.com'} )
#     buck = storage.bucket()

#     video = bucket.blob('videos/workout.mp4')
#     video.download_to_filename("workout.mp4")
#     mlmModel("workout.mp4")

#     newVideo = bucket.blob('videos/workout_normalized.mp4')
#     newVideo.upload_from_filename("workout.mp4")
    
# }



def normalize(points, indices = (11,12)):
    points = np.array(points).reshape(-1,2)
    shoulderL = points[indices[0]]
    shoulderR = points[indices[1]]
    center = (shoulderL + shoulderR)/2
    scaling_factor = np.linalg.norm(shoulderR - shoulderL)
    return ((points - center)/(scaling_factor + 1e-6)).flatten()

def smoothed(points, window_size=3):
    smoothed = []
    for i in range(len(points)):
        window = points[max(0, i - window_size + 1):i+1]
        smoothed.append(np.mean(window, axis=0))
    return smoothed

def poseCapturing(helper):
    cap = cv2.VideoCapture(helper)
    detector = PoseDetector()
    total_reps = []
    current_reps = []

    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)


    mp4 = cv2.VideoWriter_fourcc(*'avc1') #outputs an mp4 file
    out = cv2.VideoWriter('workout_normalized.mp4', mp4, fps, (width,height))

    while True:
        find, img = cap.read()
        if not find:
            break
        img = detector.findPose(img)
        lmList, bbox = detector.findPosition(img, draw=False)
        if lmList:
            points = [coord for _, x, y in lmList for coord in (x, y)]
            if len(points) >= 20:
                norm = normalize(points)
                current_reps.append(norm)

            if len(current_reps) == 20:
                total_reps.append(current_reps.copy())
                current_reps.clear()

        cv2.putText(img, f"Total reps: {len(total_reps)}", (10, 60),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 0, 255), 2)
        cv2.putText(img, f"Frames in current rep: {len(current_reps)}", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
        

        cv2.imshow("Pose", img)
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break
    return total_reps



def mlmModel(video):
    all_reps = []

    examples = ["good_bench.mp4","good_bench_2.mp4","good_bench_3.mp4","bad_bench_2.mp4","bad_bench.mp4", video]

    for example in examples:
        reps = poseCapturing(example)
        all_reps.append(reps)
    return all_reps


helper = mlmModel("output.mp4")

print(helper)









