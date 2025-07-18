# ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
import torch
import torch.nn as nn

# define general MLP
class Net_MLP(nn.Module):    
    def __init__(self,input_size,output_size,depth,width,actbool):
        # inheritance of superclass nn.Module
        super().__init__()
        
        # cal input
        self.input_size = input_size
        self.depth = depth
        self.width = width
                      
        # affine operations
        self.lin_init = nn.Linear(input_size, width)
        self.lin_hid  = nn.ModuleList([nn.Linear(width, width) for _ in range(depth - 2)])
        self.lin_out  = nn.Linear(width, output_size)
        
        # activation funstion
        if actbool == 0:
            self.act = nn.GELU()            
        if actbool == 1:
            self.act = nn.Sigmoid()            
        if actbool == 2:
            self.act = nn.ReLU()            
        if actbool == 3:
            self.act = nn.SELU()
                
    def forward(self, x):        
        # first layer
        x = self.act(self.lin_init(x))
        
        # consecutive layers
        for layer in self.lin_hid:
            x = self.act(layer(x))
            
        # final layer
        x = self.lin_out(x)        
        
        return x

def getModel(path,input_size,output_size,depth,width,afbool):
    # initialize
    model = Net_MLP(int(input_size),int(output_size),int(depth),int(width),int(afbool))
    # load state
    model.load_state_dict(torch.load(path))
    # set to evaluation mode
    model.eval()
    return model

def runBatch(model,batch):
    # numpy tensor to torch
    batch_torch = torch.tensor(batch, dtype=torch.float32)
    # run model    
    output_torch = model(batch_torch)
    # torch output to numpy
    output = output_torch.detach().numpy()
    return output
    