
# APB Protocol

This is my attempt at developing the APB Protocol (Slave).
This module takes 128 bit input and then stores the data into an asynchronous memory. The memory has an 8 bit address line and an 8 bit width. 


## Coverage
### Coverage Summary
<img width="516" alt="Coverage Summary" src="https://user-images.githubusercontent.com/85071372/178894831-b1a86197-f033-4ab2-b33e-d1f8b6e0c4d9.png">

### Functional Coverage
<img width="516" alt="APB Coverage" src="https://user-images.githubusercontent.com/85071372/178899090-1f5008f6-6efc-4f0e-b6c4-a924b9b01d90.png">


## Drawbacks
- The memory is always ready.
- The memory doesn't raise any error signal

 

