# 电控组第二次培训作业

- **薛俪卿**
- ***20263001793***

## 流水灯实现思路

本作业使用 STM32F103 + HAL 库实现三个 LED 的流水灯，切换间隔 500ms。

### 非阻塞实现原理

1. 进入主循环前，先点亮 `LED0`，并记录 `last_time = HAL_GetTick()` 作为上一次切换的基准时间。
2. `while (1)` 里每次循环都读取 `current_time = HAL_GetTick()`，算出已经过去的时间 `current_time - last_time`。
3. 当差值 `>= 500` 时，执行一次切换：
   - 关掉**当前**这盏灯
   - `current_led = (current_led + 1) % 3` 把索引移到下一盏
   - 点亮**新的当前**灯
   - 把 `last_time` 更新成 `current_time`，重新开始计时。

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
    if (current_time - last_time >= 500)        // 每过 500ms 切换一次
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

---

姓名：**薛俪卿**　学号：***20263001793***
