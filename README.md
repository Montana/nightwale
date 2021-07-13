# Nightwhale
Cron jobs for night time and business time.

The following line sets the hardware clock on the computer using the system clock as the source of an accurate time. This line is set to run at 11:03 p.m. (11 03) every day.

```bash
11 03 * * * /sbin/hwclock --systohc
```
This is correlated with my Travis builds that have Nightwhale included. The following is a "Nightwhale Sonar", in simple terms, a job that runs one minute past every hour between 9:01 a.m. and 5:01 p.m. (Business hours). 

```bash
01 09-17 * * * /usr/local/bin/nightwhale.sh
```
_I want these to run on business hours so I know if something goes wrong during peak usage._ 




