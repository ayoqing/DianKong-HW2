# 电控组第二次培训作业

<p style="font-size:56px; font-family:'Comic Sans MS','Microsoft YaHei',cursive; color:#e91e63; font-weight:bold;">薛俪卿</p>

<p style="font-size:40px; font-family:'Arial Black',sans-serif; color:#1565c0;">学号：20263001793</p>

---

## 一、作业要求

使用 CLion + CubeMX 完成三个 LED 的流水灯控制，间隔 500ms，并将工程代码与说明文档提交至 GitHub 公开仓库。

## 二、硬件与 CubeMX 配置

- 芯片：STM32F103xB（与工程编译宏 `STM32F103xB` 一致）
- 在 CubeMX 引脚图中将三个引脚设为 **GPIO_Output**，并用 **User Label** 依次命名为 `LED0`、`LED1`、`LED2`
- CubeMX 会自动在 `main.h` 中生成对应的宏，例如：

```c
#define LED0_Pin        GPIO_PIN_x
#define LED0_GPIO_Port  GPIOx
```

- 系统时钟：HSE -> PLL 9 倍频（72MHz），与工程内 `SystemClock_Config()` 配置一致。

## 三、流水灯实现思路（非阻塞版本）

本次提交采用**非阻塞延时**方式实现流水灯，核心思路如下：

1. 利用 HAL 提供的 `HAL_GetTick()` 获取系统毫秒级节拍（SysTick 每 1ms 自增一次）。
2. 记录上一次切换时间 `last_time`，在 `while (1)` 主循环里不断读取当前时间 `current_time = HAL_GetTick()`。
3. 当 `current_time - last_time >= 500` 时，说明已经过 500ms，执行一次"关掉当前灯、点亮下一盏灯"的动作，并更新 `last_time`。
4. 用 `current_led = (current_led + 1) % 3` 在三盏灯之间循环，配合 `switch` 直接调用 CubeMX 生成的 `LED0_Pin / LED0_GPIO_Port` 等宏。

**为什么不用 `HAL_Delay()`？** `HAL_Delay(500)` 是"死等"——函数内部空转 500ms，期间 CPU 什么都干不了；而 `HAL_GetTick()` 方式只在时间到了才干活，循环其余时间可自由处理其他任务，因此是非阻塞的，更适合实际工程。

### 核心代码片段（`Core/Src/main.c`）

```c
/* USER CODE BEGIN 2 */
uint32_t last_time = 0;
int current_led = 0;

HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_SET);
last_time = HAL_GetTick();
/* USER CODE END 2 */

/* Infinite loop */
while (1)
{
    /* USER CODE BEGIN 3 */
    uint32_t current_time = HAL_GetTick();
    if (current_time - last_time >= 500)
    {
      last_time = current_time;

      /* 关闭当前灯 */
      switch (current_led)
      {
        case 0: HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_RESET); break;
        case 1: HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_RESET); break;
        case 2: HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_RESET); break;
      }

      current_led = (current_led + 1) % 3;

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

## 四、编译与运行现象

- 使用 CLion 打开本工程，在 `cmake-build-debug` 配置下编译，生成 `20261025led-0.elf`。
- 烧录到开发板后，三个 LED 以 500ms 间隔依次点亮，形成流水灯效果。

## 五、提交说明

- 源码与本文档已提交至公开 GitHub 仓库（仓库地址见提交记录）。
- 作业另要求的 **CLion 编译录屏** 与 **开发板烧录后流水灯现象视频**，请按招新群要求另行录制上传。

---

姓名：薛俪卿　学号：20263001793
