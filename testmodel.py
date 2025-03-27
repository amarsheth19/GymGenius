import torch
import cv2
import matplotlib.pyplot as plt

model = torch.hub.load('ultralytics/yolov5', 'yolov5s')  # Pretrained YOLOv5 small model
def get_feedback(exercise_detected):
    if exercise_detected:
        return "Good form! Keep it up."  
    else:
        return "Exercise not detected. Try again!"

image_path = 'exercise_example.jpg' 
img = cv2.imread(image_path)
img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
results = model(img)
results.show()  

labels = results.names  
xywh = results.xywh[0]  
conf = results.conf[0] 
cls = results.cls[0] 

exercise_detected = False
for i, c in enumerate(cls):
    label = labels[int(c)]
    if label == 'person':  
        exercise_detected = True
        print(f"Person detected with confidence {conf[i]:.2f}")

feedback = get_feedback(exercise_detected)
print(feedback)

output_image = results.render()[0] 
output_image_bgr = cv2.cvtColor(output_image, cv2.COLOR_RGB2BGR)
cv2.imwrite('output_detected_image.jpg', output_image_bgr)

plt.imshow(output_image)
plt.title(feedback, fontsize=12, color='green' if exercise_detected else 'red')
plt.axis('off') 
plt.show()
