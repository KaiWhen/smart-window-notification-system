import matplotlib.pyplot as plt
import numpy as np

def plot_angles():
    actual_angles = [80, 70, 60, 50, 40, 30, 20]

    angles_ultra = [88.63, 89.85, 86.79, 84.2, 86.6, 33.81, 26.79]
    angles_ir = [79.58, 71.1, 67.91, 70, 73, 77, 79]

    # Plotting
    plt.plot(actual_angles, label='Actual Angles', marker='o')
    plt.plot(angles_ultra, label='Ultrasonic Sensor', linestyle='--', marker='x')
    plt.plot(angles_ir, label='IR Sensor', linestyle='--', marker='^')

    # Adding labels and title
    # plt.xlabel('')
    plt.ylabel('Angle (degrees)')
    plt.title('Comparison of Actual Angles with Sensor Measurements')

    # Adding legend
    plt.legend()

    # Display plot
    plt.grid(True)
    plt.show()


def plot_error():
    actual_angles = [80, 70, 60, 50, 40, 30, 20]

    angles_ultra = [88.63, 89.85, 86.79, 84.2, 86.6, 33.81, 26.79]
    angles_ir = [79.58, 71.1, 67.91, 70, 73, 77, 79]

    error_ultra = np.array(actual_angles) - np.array(angles_ultra)
    error_ir = np.array(actual_angles) - np.array(angles_ir)

    # Plotting error for each sensor
    plt.plot(error_ultra, label='Ultrasonic Sensor', linestyle='--', marker='x')
    plt.plot(error_ir, label='IR Sensor', linestyle='--', marker='^')

    plt.ylabel('Error (degrees)')
    plt.title('Error in Sensor Measurements Compared to Actual Angles')

    # Adding legend
    plt.legend()

    # Display plot
    plt.grid(True)
    plt.show()

plot_error()