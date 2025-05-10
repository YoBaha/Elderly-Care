import torch
import torch.serialization
from ultralytics.nn.tasks import DetectionModel
from ultralytics.nn.modules.conv import Conv, Concat, DWConv  # Add DWConv
from ultralytics.nn.modules.block import C2f, SPPF, C3k2, Bottleneck, C3k, C2PSA, PSABlock, Attention, DFL  # Add DFL
from ultralytics.nn.modules.head import Detect
from torch.nn.modules.container import Sequential
from torch.nn.modules.conv import Conv2d
from torch.nn.modules.batchnorm import BatchNorm2d
from torch.nn.modules.activation import SiLU
from torch.nn.modules.upsampling import Upsample
from ultralytics.nn.modules.conv import Conv, Concat  # Fix Concat import
from torch.nn.modules.container import Sequential, ModuleList  # Add ModuleList
from torch.nn.modules.pooling import MaxPool2d  # Add MaxPool2d
from torch.nn.modules.linear import Identity  # Corrected import

torch.serialization.add_safe_globals([DetectionModel, Sequential, Conv, Conv2d, BatchNorm2d, C2f, SPPF, Detect, SiLU, Upsample, Concat, C3k2, ModuleList, Bottleneck, C3k, MaxPool2d, C2PSA, PSABlock, Attention, Identity, DWConv, DFL])
model_path = "my_model.pt"
try:
    checkpoint = torch.load(model_path, map_location="cpu", weights_only=True)
    print("Successfully loaded model with weights_only=True")
except Exception as e:
    print(f"Error: {e}")