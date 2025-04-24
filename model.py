from cvzone.PoseModule import PoseDetector
import cv2


def poseCapturing(helper):
    cap = cv2.VideoCapture(helper)
    detector = PoseDetector()
    while True:
        find, img = cap.read()
        if not find:
            break
        img = detector.findPose(img)
        lmList, bbox = detector.findPosition(img, draw=False)
        cv2.imshow("Pose", img)
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break


    

def mlmModel():
    examples = ["good_bench.mp4","good_bench_2.mp4","good_bench_3.mp4","bad_bench_2.mp4","bad_bench.mp4"]
    poseCapturing("backend/processed_output.mp4")


mlmModel()










