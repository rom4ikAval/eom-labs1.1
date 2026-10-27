cd /workspaces/eom-labs1.1/labs/lab03-build-elf-memory && cat > README.md <<'README'
# Лабораторна робота №3
## Побудова програми, ELF та організація пам’яті

**Виконав:** Платонов Роман Віталійович.  
**Середовище:** GitHub Codespaces 
**Інструменти:** GCC 13.3.0, GNU Binutils 2.42.  

## 1. Мета роботи

Дослідити етапи побудови C-програми, символи та компонування,
структуру ELF, динамічні бібліотеки й розміщення даних у пам’яті процесу.

## 2. Етапи build pipeline

| Файл | Етап | Що містить | Чи можна виконати як готову програму? |
|---|---|---|---|
| `.c` | Початковий код | Текст мовою C | Ні |
| `.i` | Preprocessing | C після обробки директив і включення заголовків | Ні |
| `.s` | Compilation | Текст Assembly для x86-64 | Ні |
| `.o` | Assembly | Машинний код, дані, символи та relocation records | Ні, потрібне компонування |
| Executable | Linking | ELF із кодом, даними й інформацією для завантаження | Так, після завантаження ОС і підготовки залежностей |

CPU виконує машинні інструкції в пам’яті, а не ELF-файл як контейнер.
Об’єктний файл уже містить машинний код, але не є готовою програмою.

### Результати для program.c

- `program.c`: **16 рядків**.
- `program.i`: **829 рядків**; `main` знайдено в рядку **824**.
- Збільшення спричинене включенням вмісту `stdio.h` та інших заголовків.
- `#include` оброблено препроцесором; `.i` залишається текстом C.
- `program.s`: `assembler source, ASCII text`, Intel syntax.
- У ньому знайдено `add:` і `main:`; додавання реалізовано `add eax, edx`.
- `program.o`: `ELF 64-bit LSB relocatable, x86-64`.
- Перші байти `.o`: `7f 45 4c 46` — сигнатура ELF.
- `objdump` показав у функції `add` інструкцію `01 d0` — `add eax, edx`.
- Після компонування програма вивела **`Result: 30`**.

На відміну від текстового `.s`, `.o` є бінарним файлом.
Для перегляду його байтів використано `od`, а для дизасемблювання — `objdump`.

## 3. Symbols та linker error

Результат `nm program.o`:

| Symbol | Позначення | Значення |
|---|:---:|---|
| `add` | T | Функцію визначено в коді |
| `main` | T | Функцію визначено в коді |
| `global_value` | D | Ініціалізовані дані |
| `global_empty` | B | Дані в .bss |
| `printf` | U | Зовнішній, тут не визначений символ |

`program.o` містить реалізації `add` і `main`, але не `printf`.

Компіляція `main.c` в `main.o` завершилась успішно:
оголошення `calculate` дозволяє перевірити її виклик.
Компонування лише `main.o` завершилось помилкою:

```text
undefined reference to `calculate'
collect2: error: ld returned 1 exit status
```

Причина: визначення функції не було серед вхідних файлів компонувальника.

Після створення `calculate.o` отримано:

- `main.o`: `U calculate`;
- `calculate.o`: `T calculate`.

Команда `gcc main.o calculate.o -o app` усунула помилку.
Програма `app` вивела **`30`**.

## 4. Аналіз ELF

Результати `readelf -h program`:

| Властивість | Фактичне значення |
|---|---|
| Class | ELF64 |
| Data | 2's complement, little endian |
| Type | DYN (Position-Independent Executable file) |
| Machine | Advanced Micro Devices X86-64 |
| Entry point | `0x1060` |
| Кількість section headers | 31 |

ELF64 означає 64-бітний формат ELF. Machine вказує ISA x86-64.
У цьому випадку DYN позначає PIE executable, а не звичайну бібліотеку.
Entry point — точка входу, не обов’язково адреса `main`.

`file` також визначив динамічне компонування та інтерпретатор
`/lib64/ld-linux-x86-64.so.2`.

### Секції program

| Секція | Адреса в ELF | Розмір, байт | Зв’язок із програмою |
|---|---|---:|---|
| `.text` | `0x1060` | 322 | Код `add`, `main` і службових функцій |
| `.rodata` | `0x2000` | 16 | Зокрема рядок `"Result: %d\n"` |
| `.data` | `0x4000` | 20 | Зокрема `global_value = 10` |
| `.bss` | `0x4014` | 12 | Зокрема `global_empty` |

Це адреси з ELF, а не абсолютні адреси поточного процесу.
Для PIE під час завантаження враховується базова адреса.

## 5. Перевірка .data, .bss та .rodata

Програма `sections` вивела:

```text
123 0 456 0 Computer Systems
```

| Об’єкт | Адреса з nm | Symbol type | Секція |
|---|---|:---:|---|
| `initialized` | `0x4010` | D | `.data` |
| `static_initialized` | `0x4014` | d | `.data` |
| `uninitialized` | `0x401c` | B | `.bss` |
| `static_uninitialized` | `0x4020` | b | `.bss` |
| `message` | `0x2010` | R | `.rodata` |

Малі `d` і `b` відповідають локальним символам статичних змінних.

У дампі `.data` знайдено:

- `7b 00 00 00` — число 123;
- `c8 01 00 00` — число 456.

Це little-endian представлення.
У `.rodata` знайдено текст `Computer Systems`.
Неініціалізовані глобальні та статичні змінні на старті дорівнюють нулю.

## 6. Експеримент із великою .bss

Прогноз: великий неініціалізований масив збільшить `.bss`,
але не спричинить такого самого збільшення файла.

Замість `int uninitialized;` створено `int large_array[100000];`.
У `printf` використано `large_array[0]`, щоб змінена програма компілювалася.

| Варіант | text, байт | data, байт | bss, байт | Розмір файла, байт |
|---|---:|---:|---:|---:|
| `sections` | 1450 | 608 | 16 | 16144 |
| `sections_large` | 1450 | 608 | 400040 | 16160 |
| Зміна | 0 | 0 | +400024 | +16 |

Масив займає 400000 байт у дослідженому середовищі.
Зміна загальної `.bss` також враховує заміну попереднього об’єкта
та вирівнювання.

`.bss` має тип `NOBITS`: нульові байти не зберігаються у файлі
як повний масив. Під час завантаження для них забезпечується
нульова пам’ять. Прогноз підтверджено.

Поля `text` і `data` команди `size` є сумарними категоріями:
їх не слід ототожнювати лише із секціями `.text` та `.data`.

## 7. Dynamic linking

`ldd program` показав:

```text
linux-vdso.so.1
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
/lib64/ld-linux-x86-64.so.2
```

`printf` надається бібліотекою libc; її повна реалізація
не скопійована у наш executable.
`.so` означає shared object.

Динамічний завантажувач підключає потрібні бібліотеки та розв’язує
динамічні посилання. Різні процеси можуть використовувати спільні
фізичні сторінки коду бібліотеки, маючи власний стан даних.
Це зменшує дублювання коду на диску й у пам’яті.
`linux-vdso` надається ядром і не є звичайним бібліотечним файлом.

## 8. Executable та process

`process` до запуску — виконуваний файл.
Після запуску створено процес із **PID 3803**.

`ps` показав:

```text
PID   PPID  STAT  COMMAND
3803  2483  S     process
```

Стан `S` відповідає очікуванню під час `sleep(60)`.

У `/proc/3803/maps` знайдено відображення executable, libc,
динамічного завантажувача, `[heap]` і `[stack]`.
Процес має власний PID, адресний простір і стан виконання;
файл сам по собі цього не має.

## 9. Прогноз і результат розміщення об’єктів

Прогноз записано перед запуском.

| Об’єкт memory.c | Очікувана область | Адреса в першому запуску |
|---|---|---|
| `main` | code | `0x57971daf31a9` |
| `global_initialized` | `.data` | `0x57971daf6010` |
| `static_initialized` | `.data` | `0x57971daf6014` |
| `global_uninitialized` | `.bss` | `0x57971daf601c` |
| `static_uninitialized` | `.bss` | `0x57971daf6020` |
| `local` | stack | `0x7ffcfba54e1c` |
| Виділений блок `dynamic` | heap | `0x57973a0052a0` |

Глобальні та статичні змінні згруповані поруч.
`global_initialized` і `global_uninitialized` розділяє 12 байт.
Локальна змінна та блок malloc розташовані в інших ділянках.

Спостереження узгоджуються з прогнозом.
Самих адрес недостатньо для визначення ELF-секції:
їх інтерпретацію доповнюють `nm`, `readelf`, тип і тривалість зберігання об’єктів.

`dynamic` — локальний вказівник; виведено адресу виділеного блока,
а не адресу самого вказівника.

### Повторні запуски

| Запуск | main | global_initialized | local | malloc |
|---|---|---|---|---|
| 1 | `0x57971daf31a9` | `0x57971daf6010` | `0x7ffcfba54e1c` | `0x57973a0052a0` |
| 2 | `0x5873422d41a9` | `0x5873422d7010` | `0x7ffe8669726c` | `0x58734c7b72a0` |
| 3 | `0x567824b1f1a9` | `0x567824b22010` | `0x7ffc0a0029dc` | `0x56782c9302a0` |

Адреси змінюються. Це узгоджується з ASLR та використанням PIE.
Точні адреси не повинні повторюватися для відтворення експерименту.

## 10. Stack та heap

### Stack

| Виклик | Адреса локальної змінної |
|---|---|
| `level1` | `0x7ffc62434254` |
| `level2` | `0x7ffc62434234` |
| `level3` | `0x7ffc62434214` |

При вкладених викликах адреси зменшилися на `0x20`, тобто 32 байти,
на кожному кроці. Це узгоджується зі зростанням стека до менших адрес
у дослідженому x86-64 середовищі при `-O0`.
Це не універсальне правило для всіх ISA, ABI та оптимізацій.

### Heap

Прогноз: malloc не зобов’язаний повертати послідовні адреси.

| Блок | Адреса |
|---|---|
| a | `0x61385046a2a0` |
| b | `0x61385046a2c0` |
| c | `0x61385046a2e0` |

У цьому запуску відстань між адресами становила 32 байти.
Виділявся лише `sizeof(int)`: більша відстань пов’язана
з організацією та вирівнюванням блоків allocator.
Такий порядок не гарантується malloc.
Усі блоки звільнено через `free`.

## 11. Підсумкова memory map

Програма `memory_map.c` пройшла окремі етапи
`.c → .i → .s → .o → executable` і вивела адреси всіх восьми об’єктів.

Концептуальна карта нижче впорядкована від вищих адрес до нижчих
за результатом одного запуску:

| Область | Об’єкт | Фактична адреса |
|---|---|---|
| Stack | `local` | `0x7ffd801c4494` |
| Heap | Блок malloc | `0x63e9f628e2a0` |
| `.bss` | `static_uninitialized` | `0x63e9ca261020` |
| `.bss` | `global_uninitialized` | `0x63e9ca26101c` |
| `.data` | `static_initialized` | `0x63e9ca261014` |
| `.data` | `global_initialized` | `0x63e9ca261010` |
| `.rodata` | Літерал `"Computer Systems"` | `0x63e9ca25f004` |
| `.text` | `example_function` | `0x63e9ca25e1a9` |

Між областями є пропуски; таблиця не є точною картою всього процесу.

`nm` показав `example_function` за адресою ELF `0x11a9`,
ініціалізовані змінні — `0x4010` і `0x4014`,
неініціалізовані — `0x401c` і `0x4020`.
`objdump` підтвердив літерал у `.rodata` з адреси ELF `0x2004`.
Ці значення узгоджуються з базою завантаження `0x63e9ca25d000`.

## 12. Команди для відтворення

Виконувати в Bash із папки цієї лабораторної.
Проміжні файли та executables створюються в `/tmp/eom-lab03`.
Точні адреси, PID і деякі розміри можуть залежати від середовища.

```bash
mkdir -p /tmp/eom-lab03
gcc --version
readelf --version
objdump --version

gcc -Wall -Wextra -O0 program.c -o /tmp/eom-lab03/program
/tmp/eom-lab03/program

gcc -E program.c -o /tmp/eom-lab03/program.i
wc -l program.c /tmp/eom-lab03/program.i
head -n 30 /tmp/eom-lab03/program.i
grep -n "int main" /tmp/eom-lab03/program.i
gcc -S -O0 -masm=intel /tmp/eom-lab03/program.i -o /tmp/eom-lab03/program.s
cat /tmp/eom-lab03/program.s
gcc -c /tmp/eom-lab03/program.s -o /tmp/eom-lab03/program.o
od -An -tx1 -N64 /tmp/eom-lab03/program.o
objdump -d -M intel /tmp/eom-lab03/program.o
nm /tmp/eom-lab03/program.o
gcc /tmp/eom-lab03/program.o -o /tmp/eom-lab03/program
file program.c /tmp/eom-lab03/program.{i,s,o} /tmp/eom-lab03/program
/tmp/eom-lab03/program

gcc -Wall -Wextra -O0 -c main.c -o /tmp/eom-lab03/main.o
# Очікувана linker error:
gcc /tmp/eom-lab03/main.o -o /tmp/eom-lab03/app
# Виправлення:
gcc -Wall -Wextra -O0 -c calculate.c -o /tmp/eom-lab03/calculate.o
nm /tmp/eom-lab03/main.o /tmp/eom-lab03/calculate.o
gcc /tmp/eom-lab03/main.o /tmp/eom-lab03/calculate.o -o /tmp/eom-lab03/app
/tmp/eom-lab03/app

readelf -h /tmp/eom-lab03/program
readelf -SW /tmp/eom-lab03/program

gcc -Wall -Wextra -O0 sections.c -o /tmp/eom-lab03/sections
/tmp/eom-lab03/sections
nm /tmp/eom-lab03/sections
readelf -SW /tmp/eom-lab03/sections
objdump -s -j .data /tmp/eom-lab03/sections
objdump -s -j .rodata /tmp/eom-lab03/sections

sed -e 's/int uninitialized;/int large_array[100000];/' \
    -e 's/initialized, uninitialized,/initialized, large_array[0],/' \
    sections.c > /tmp/eom-lab03/sections_large.c
gcc -Wall -Wextra -O0 /tmp/eom-lab03/sections_large.c -o /tmp/eom-lab03/sections_large
/tmp/eom-lab03/sections_large
size /tmp/eom-lab03/sections /tmp/eom-lab03/sections_large
stat -c '%n: %s bytes' /tmp/eom-lab03/sections /tmp/eom-lab03/sections_large
ldd /tmp/eom-lab03/program

gcc -Wall -Wextra -O0 process.c -o /tmp/eom-lab03/process
/tmp/eom-lab03/process &
lab03_pid=$!
ps -p "$lab03_pid" -o pid,ppid,stat,comm,args
cat "/proc/$lab03_pid/maps"

gcc -Wall -Wextra -O0 memory.c -o /tmp/eom-lab03/memory
for run in 1 2 3; do
    echo "Memory run $run"
    /tmp/eom-lab03/memory
done

gcc -Wall -Wextra -O0 stack.c -o /tmp/eom-lab03/stack
/tmp/eom-lab03/stack
gcc -Wall -Wextra -O0 heap.c -o /tmp/eom-lab03/heap
/tmp/eom-lab03/heap

gcc -Wall -Wextra -E memory_map.c -o /tmp/eom-lab03/memory_map.i
gcc -Wall -Wextra -S -O0 -masm=intel /tmp/eom-lab03/memory_map.i -o /tmp/eom-lab03/memory_map.s
gcc -c /tmp/eom-lab03/memory_map.s -o /tmp/eom-lab03/memory_map.o
gcc /tmp/eom-lab03/memory_map.o -o /tmp/eom-lab03/memory_map
file memory_map.c /tmp/eom-lab03/memory_map.{i,s,o} /tmp/eom-lab03/memory_map
/tmp/eom-lab03/memory_map
nm -n /tmp/eom-lab03/memory_map
readelf -SW /tmp/eom-lab03/memory_map
objdump -s -j .rodata /tmp/eom-lab03/memory_map
```

## 13. Відповіді на контрольні питання

1. **Етапи побудови:** preprocessing, compilation, assembly, linking.
2. **Preprocessor:** обробляє директиви, включає заголовки, розгортає макроси.
3. **Compiler:** у дослідженому pipeline створює Assembly із C.
4. **Assembler:** перетворює Assembly на об’єктний файл із машинним кодом.
5. **Object file:** містить код, дані, символи та інформацію про переміщення.
6. **Linker:** об’єднує об’єктні файли, розв’язує посилання й формує executable.
7. **Undefined reference:** потрібне визначення символу не знайдено під час компонування.
8. **Symbol:** ім’я функції або об’єкта з інформацією, потрібною інструментам побудови.
9. **Header і library:** заголовок містить оголошення, типи й макроси; бібліотека надає реалізації. Заголовок також може містити inline-визначення.
10. **ELF:** Executable and Linkable Format — формат об’єктних файлів, executables і shared libraries.
11. **.text:** машинні інструкції функцій.
12. **.rodata:** дані лише для читання, наприклад рядкові літерали.
13. **.data і .bss:** .data зберігає початкові значення; .bss описує область нульової ініціалізації без повного зберігання нулів у файлі.
14. **Велика .bss:** збільшує потребу в пам’яті, але не додає відповідний масив нулів до executable.
15. **ldd:** показує залежності від динамічних бібліотек та їх розташування.
16. **Executable і process:** executable — файл; process — його запущений екземпляр із PID, пам’яттю та станом.
17. **Local variables:** у дослідженому коді при -O0 розташовані на стеку; оптимізатор може використовувати регістри або усувати змінні.
18. **Heap:** використовується для динамічного виділення пам’яті.
19. **Stack і heap:** стек обслуговує виклики та автоматичні об’єкти; час життя виділеної пам’яті визначається malloc/free.
20. **Зміна адрес:** пов’язана, зокрема, з ASLR; PIE дозволяє змінювати базу завантаження executable.
21. **Temporal locality:** нещодавно використані дані або інструкції ймовірно будуть використані знову.
22. **Spatial locality:** після доступу до певної адреси ймовірний доступ до сусідніх адрес.

## Висновок

Експериментально виконано повний build pipeline, створено та виправлено
linker error, досліджено ELF і symbols. Підтверджено розміщення даних
у .data, .bss та .rodata, підключення libc і відмінність файла від процесу.
Великий масив збільшив .bss на 400024 байти, тоді як файл зріс на 16 байт.
Досліджено зміну адрес між запусками, вкладені виклики, malloc
і побудовано концептуальну карту пам’яті власної програми.
README