from cvzone.PoseModule import PoseDetector
import cv2
import numpy as np

def normalize(points, indices = (11,12)):
    points = np.array(points).reshape(-1,2)
    shoulderL = points[indices[0]]
    shoulderR = points[indices[1]]
    center = (shoulderL + shoulderR)/2
    scaling_factor = np.linalg.norm(shoulderR - shoulderL)
    return ((points - center)/(scaling_factor + 1e-6)).flatten()



def poseCapturing(helper):
    cap = cv2.VideoCapture(helper)
    detector = PoseDetector()
    total_reps = []
    current_reps = []

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

        cv2.putText(img, f"Frames in current rep: {len(current_reps)}", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
        cv2.putText(img, f"Total reps: {len(total_reps)}", (10, 60),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 0), 2)

        cv2.imshow("Pose", img)
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break
    return total_reps



def mlmModel():
    all_reps = []
    examples = ["output.mp4", "good_bench.mp4","good_bench_2.mp4","good_bench_3.mp4","bad_bench_2.mp4","bad_bench.mp4"]
    for example in examples:
        reps = poseCapturing(example)
        all_reps.append(reps)
    return all_reps

def smoothed(points, window_size=3):
    smoothed = []
    for i in range(len(points)):
        window = points[max(0, i - window_size + 1):i+1]
        smoothed.append(np.mean(window, axis=0))
    return smoothed



helper = mlmModel()
print(helper)









