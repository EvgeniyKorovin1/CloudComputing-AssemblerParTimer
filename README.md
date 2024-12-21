<a><img src="Data/poster.jpg"></a>

# CloudComputing-AssemblerParTimer
This project presents the completion of one of the achievements of the course "Building distributed systems and cloud computing". The task is devoted to the development of a program in the AVR Assembler language for the Atmega8 microcontroller. Two parallel timers are launched, when the first one is triggered, the line "ping\r\n" is displayed, when the second one is triggered, "pong\r\n", through the USART interface, you can change the timer intervals, line output texts and restart the timers. In addition, below is a text explanation about the minimum values ​​​​of the timer intervals at which the program works correctly.

## Сontents
- [Question from point two](#question)
- [Distribute](#distribute)
- [Developers](#developers)
- [Contributing](#contributing)
- [License](#license)

## Question
The minimum total value of the TIMER1_INTERVAL and TIMER2_INTERVAL intervals, which ensures correct program operation with a minimum accuracy of 4 clock cycles, is 4. This condition follows from the need to comply with the lower limit of interval resolution. If the total interval is less than 4 clock cycles, none of the timers will be able to form a time interval adequate for reliable and predictable interrupt generation. With a sum equal to 4, sufficient minimum time discreteness is ensured, at which the system is able to stably call and process timer interrupts without violating the correctness of the program operation.

## Distribute
- [GitHub repository](https://github.com/EvgeniyKorovin1/CloudComputing-AssemblerParTimer)

## Developers
- [Evgeniy Korovin](https://github.com/EvgeniyKorovin1) — Software Engineer

## Contributing
To send feedback on the project or other interaction that can be associated with it, please use [email](https://mail.google.com/mail/?view=cm&fs=1&to=korovinevgeniyalexeyevich@gmail.com&su=CloudComputing-AssemblerParTimer), indicating the [repository](https://github.com/EvgeniyKorovin1/CloudComputing-AssemblerParTimer) as the subject of the letter.

## License
The license for the use of materials from this project can be viewed - [LICENSE](LICENSE).
