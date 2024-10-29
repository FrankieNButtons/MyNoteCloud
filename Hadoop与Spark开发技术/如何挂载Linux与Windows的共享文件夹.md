### 总体操作步骤
 1. 虚拟机`设置` -> `选项` -> `共享文件夹`；
 2. 输入以下指令进行虚拟盘挂载：
```bash
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other
```
 3. 挂载成功后，在`/mnt/hgfs`目录下可以看到你的共享文件夹。