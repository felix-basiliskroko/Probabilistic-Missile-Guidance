from keras.src.callbacks import ModelCheckpoint, TensorBoard
from tensorflow.keras.layers import Convolution2D, MaxPooling2D, Dropout, Flatten, Dense, BatchNormalization
from tensorflow.keras import Sequential
import tensorflow.keras as tfk
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import os
import datetime

tfk.backend.clear_session()
USE_BN = True  # Use BatchNormalization

# Define the model
model = Sequential()
model.add(Dense(256, activation='relu'))
if USE_BN:
    model.add(BatchNormalization())
model.add(Dropout(0.3))

model.add(Dense(256, activation='relu'))
if USE_BN:
    model.add(BatchNormalization())
model.add(Dropout(0.3))

model.add(Dense(64, activation='relu'))
if USE_BN:
    model.add(BatchNormalization())
model.add(Dropout(0.3))

model.add(Dense(1, activation='sigmoid'))

# Compile the model
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
model.summary()

# Load the CSV file
df = pd.read_csv("../kin_engagement_dataset.csv")

# Split the data into features and labels
X = df.drop(columns=['hit_flag', 'miss_distance', 'hit_time'])
y = df['hit_flag']

# Train and test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=69)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Define the log directory for TensorBoard
log_dir = os.path.join("logs", datetime.datetime.now().strftime("%Y%m%d-%H%M%S"))
tensorboard_callback = TensorBoard(log_dir=log_dir, histogram_freq=1)

# Define the checkpoint callback
checkpoint_filepath = "best_model.h5"
model_checkpoint_callback = ModelCheckpoint(
    filepath=checkpoint_filepath,  # Filepath to save the model
    monitor='val_accuracy',        # Metric to monitor (validation accuracy)
    save_best_only=True,           # Save only when val_accuracy improves
    mode='max',                    # Maximize validation accuracy
    verbose=1                      # Print when a new best model is saved
)

# Train the model with both callbacks
model.fit(
    X_train, y_train,
    epochs=40,
    batch_size=128,
    validation_data=(X_test, y_test),
    callbacks=[tensorboard_callback, model_checkpoint_callback]  # Add both callbacks
)