## packer-ami-aws

copy packer binary file to the folder

`packer init .`

`packer.exe validate --var-file packer-vars.json packer.json`

`packer.exe inspect --var-file=packer-vars.json packer.json`

`packer.exe build --var-file=packer-vars.json packer.json`

Please ensure:
```
- Auto assign public ip for the subnets
- SSH is allowed in SG
- 'amazon-ebs' packer plugin is installed
- Instance should be in public subnet
- Proper routing in RT
```

![image](https://github.com/user-attachments/assets/94988679-200d-4df4-b7f4-0e10c4392bbd)
