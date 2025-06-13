#!/bin/bash

sum=0 #Инициализируем сумму как ноль

echo "Введите числа построчно. Введите 0 для окончания и вывода суммы"

#Чтение строк
while read -r number; do
	if ! [[ "$number" =~ ^-?[0-9]+$ ]]; then
        	echo "Ошибка: '$number' не является числом или целым числом. Пожалуйста, введите целое число!"
        	continue
	fi

	if [ "$number" -eq 0 ]; then
        	break
	fi

    	sum=$((sum + number))
done

echo "Сумма введенных чисел: "$sum""

