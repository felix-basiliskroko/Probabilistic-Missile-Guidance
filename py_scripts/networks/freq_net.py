import torch
import torch.nn as nn


class FreqNet(nn.Module):
    def __init__(self):
        super(FreqNet, self).__init__()
        self.dense1 = nn.Linear(10, 256)
        self.dense2 = nn.Linear(256, 256)
        self.dense3 = nn.Linear(256, 64)
        self.dense4 = nn.Linear(64, 1)
        self.relu = nn.ReLU()

    def forward(self, x):
        x = self.relu(self.dense1(x))
        x = self.relu(self.dense2(x))
        x = self.relu(self.dense3(x))
        x = self.dense4(x)
        return x
