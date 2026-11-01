# 电控组第二次培训作业

- **薛俪卿**
- ***20263001793***

## 流水灯实现思路

本作业使用 STM32F103 + HAL 库实现三个 LED 的流水灯，切换间隔 500ms。下面**重点说明我完成的非阻塞延时（加分项）的具体实现原理与核心代码**。

### 为什么用非阻塞而不是 HAL_Delay

`HAL_Delay(500)` 是"死等"：函数内部靠一个空循环把 CPU 占满整整 500ms，期间程序什么都干不了，纯属浪费。

我改用 `HAL_GetTick()`。它返回芯片自启动以来的毫秒数（由 SysTick 定时器每 1ms 自增一次）。用"看时间"代替"等时间"，主循环始终在转，到点了才切一次灯——这就是**非阻塞**。

### 非阻塞实现原理

1. 进入主循环前，先点亮 `LED0`，并记录 `last_time = HAL_GetTick()` 作为上一次切换的基准时间。
2. `while (1)` 里每次循环都读取 `current_time = HAL_GetTick()`，算出已经过去的时间 `current_time - last_time`。
3. 当差值 `>= 500` 时，说明已经过了 500ms，执行一次切换：
   - 关掉**当前**这盏灯；
   - `current_led = (current_led + 1) % 3` 把索引移到下一盏（到 2 之后回到 0，形成循环）；
   - 点亮**新的当前**灯；
   - 把 `last_time` 更新成 `current_time`，重新开始计时。
4. 还没到 500ms 时，循环体什么都不做，直接回到开头继续"看表"。这样 CPU 在等待期间完全空闲，可以随时去处理按键、通信等其他任务。

三盏灯在 CubeMX 里用 User Label 分别命名为 `LED0`、`LED1`、`LED2`，CubeMX 会自动在 `main.h` 中生成对应的宏。代码里直接调用这些宏（`LEDx_Pin` / `LEDx_GPIO_Port`），不需要手写任何引脚号。

### 核心代码片段（Core/Src/main.c）

```c
/* USER CODE BEGIN 2 */
uint32_t last_time = 0;
int current_led = 0;

HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_SET);  // 先点亮 LED0
last_time = HAL_GetTick();
/* USER CODE END 2 */

/* Infinite loop */
while (1)
{
    /* USER CODE BEGIN 3 */
    uint32_t current_time = HAL_GetTick();
    if (current_time - last_time >= 500)        // 每过 500ms 才切换一次
    {
      last_time = current_time;

      /* 关闭当前灯 */
      switch (current_led)
      {
        case 0: HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_RESET); break;
        case 1: HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_RESET); break;
        case 2: HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_RESET); break;
      }

      current_led = (current_led + 1) % 3;       // 移到下一盏，到头回 0

      /* 点亮下一个灯 */
      switch (current_led)
      {
        case 0: HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_SET); break;
        case 1: HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET); break;
        case 2: HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_SET); break;
      }
    }
}
/* USER CODE END 3 */
```

## 编译与运行

- 用 CLion 打开本工程，在 `cmake-build-debug` 配置下编译，生成 `20261025led-0.elf`。
- 烧录到开发板后，三个 LED 以 500ms 间隔依次点亮，形成流水灯效果。

## 提交说明

- 源码与本文档已提交至公开 GitHub 仓库（仓库地址见提交记录）。
- 作业另要求的 CLion 编译录屏与开发板烧录后流水灯现象视频，请按招新群要求另行录制上传。

---

姓名：**薛俪卿**　学号：***20263001793***
