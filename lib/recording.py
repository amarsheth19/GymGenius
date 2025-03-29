import cv2

def recording(output_file = 'output.mp4'):
    camera = cv2.VideoCapture(0) #Sets up the camera
    camera.set(cv2.CAP_PROP_FRAME_WIDTH, 1920) # Makes camera makes resolution
    camera.set(cv2.CAP_PROP_FRAME_HEIGHT, 1080)
    camera.set(cv2.CAP_PROP_FPS, 20)  # Try reducing FPS


    mp4 = cv2.VideoWriter_fourcc(*'avc1') #outputs an mp4 file
    out = cv2.VideoWriter('output.mp4', mp4, 30.0, (1920,1080))


    while camera.isOpened():
        ret, frame = camera.read()
        if not ret: #if the camera is not reading anything just break out of the for loop
            break
        out.write(frame) 
        cv2.imshow('Recording', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'): #Ends when user presses q
            break

    camera.release()
    out.release()
    cv2.destroyAllWindows()


recording(output_file= "output.mp4") #Calls the function






