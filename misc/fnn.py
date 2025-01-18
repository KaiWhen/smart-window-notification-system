import numpy as np
import pandas as pd
from keras.models import Sequential
from keras.layers import Dense


df1 = pd.read_csv("data/train/s1.csv").drop('TIME', axis=1)
df2 = pd.read_csv("data/train/s2.csv").drop('TIME', axis=1)
df3 = pd.read_csv("data/train/s3-35.csv")

df_merged = pd.concat([df1, df2, df3], ignore_index=True, sort=False).drop('Unnamed: 0', axis=1)
targets = df_merged.iloc[:, 15]
df_merged = df_merged.drop('Target', axis=1)

values = df_merged.values
target_values = targets.values

print(values[0])

# model
model = Sequential()
model.add(Dense(15, input_dim=15, activation='relu'))
model.add(Dense(11, activation='relu'))
model.add(Dense(1, activation='sigmoid'))
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

# Train the model
model.fit(values, target_values, epochs=8, batch_size=32)

# Save model
model.save("models/model1.keras")

# # Evaluate the model
_, accuracy = model.evaluate(values, target_values)
print('Accuracy: %.2f' % (accuracy*100))

# predict
indoor_sample = np.array([[1, 21.1, 47.8, 1667, 305, 6, 15, 13]])  # Sample indoor data for prediction
outdoor_sample = np.array([[7.5, 91.6, 1849, 493, 32, 63, 57]])  # Sample outdoor data for prediction
prediction = model.predict(np.concatenate((indoor_sample, outdoor_sample), axis=1))
print('Prediction:', prediction)
