# Ceres Lua Template

Данный репозиторий основан на первоначальном репозитории проекта Ceres https://github.com/ceres-wc3/ceres-lua-template с небольшими изменениями в конфигурации сборки, ресурса карты, списка файлов, входящих в git-систему управления версиями.


# Установка и эксплуатация

Для быстрой установки пропишите сначала в файле .bashrc, который должен находиться у вас по пути C:\Users\$USERNAME\ на Windows (можете его создать там) или ~/ на Linux, следующие алиасы и функции (они понадобятся, чтобы вводить краткие команды):

`alias clone='gh repo clone'`
`alias remote='git remote set-url origin'`
`alias pull='git pull'`
`alias push='git push'`
`alias setup='source ./install'`

`function create(){`
`    gh repo create $1/$2`
`    clone $1/$2`
`}`

`function a-clone(){`
`	clone $1/$2`
`	cd $2`
`	remote $3`
`}`

`function a(){`
`	git add --all`
`	git commit -m "$1"`
`}`

`function ap(){`
`	a $1`
`	push`
`}`

`function apm(){`
`    cd $1`
`    ap $2`
`    cd ..`
`}`

`function asUser(){`
`    git config user.name $USERNAME`
`    git config user.email $email`
`}`

`alias rm="rm -rf"`
`alias cp="cp -r"`
`alias c=clear`

`function setup(){`
`    source ./$1/install`
`}`

`function req(){`
`	clone $1/$2`
`	cd $2`
`	pull`
`	cd ..`
`    setup $2`
`}`

`function mkcd(){`
`	mkdir $1`
`	cd $1`
`}`

`function update(){`
`    cd ..`
`    setup`
`    cd modules`
`}`

`function ceres-b(){`
`    cd ..`
`    ceres build -- --map $1.w3x --output mpq`
`    cd modules`
`}`

`function ceres-r(){`
`    cd ..`
`    ceres run -- --map $1.w3x --output mpq`
`    cd modules`
`}`
`function l-ceres-b(){`
`	ceres-b $1`
`}`
`export WARCRAFT_PATH='path/to/warcraft iii.exe'`
`function l-ceres-r(){`
`	l-ceres-b $1`
`	wine '$WARCRAFT_PATH' -loadfile ./target/$1.w3x -launch -windowmode -windowed`
`}`

Установите программы Git, Github Cli, возьмите на вооружение bash-терминал. Откройте его, и далее напишите первым `cd <желаемое место, где будет находиться папка проекта>`. И чтобы установить данный проект, воспользуйтесь командой `req wc3lua ceres-lua-template`

При эксплуатации пользуйтесь дополнительными вещами, заданными уже этим репозиторием. Подключайте все модули в исходный скрипт через файл main.lua в начале относительного пути проекта.
На Linux запускайте тест карты через функцию `l-ceres-r test`, где test - имя карты в директории maps. Запускаете эту команду, находясь только в папке modules, так устроена функция. Устроена она так для того, чтобы было удобнее обновлять изменения модулей, пользуясь командой-функцией `apm <module-name> <message>`, где <module-name> - имя модуля в папке modules, а message - текст для коммита и добавления изменений в репозиторий github. Предварительно вам нужно также еще настроить переменную WARCRAFT_PATH. И еще должен быть установлен wine плюс подготовлен к запуску Warcraft (для PTR и Reforged следуйте инструкциям в этой статье https://www.reddit.com/r/WC3/comments/dsijcy/reforged_works_under_linux/).

Так же для отдельной компиляции (чтоб не запускался Warcraft, если не скомпилировалась карта из-за ошибок) предусмотрен для запуска ceres-b с аналогичным параметром (или l-ceres-b).

На Windows, соответственно, пользуетесь теми же командами, для запуска просто `ceres-r <map_name in maps dir>`.


# Разработка проекта

При разработке проекта вы можете работать как над исходным кодом, так и над кодом модулей, пользуясь при этом системой git управления версиями. Вы первым делом после открытия проекта в редакторе переходите в папку modules: `cd modules`. Если вам необходимо скачать изменения проекта, внесенные другими разработчиками, выполняете файл install, набирая команду `update`. Далее остаетесь всегда в папке modules, и для обновления внешнего репозитория пишите `ap <message>`, где <message> - сообщение коммита, не заключенное в "". Для обновления модулей: `apm <module_name> <message>`, где <module_name> - папка модуля, <message> - тоже сообщение описания изменений без кавычек.



Чтобы заливать на свой сервер github изменения репозиториев, склонированных и взятых у других владельцев, нужно привязывать их прежде к своему созданному репозиторию. Сделать это можно, следуя данной инструкции https://devacademy.ru/recipe/kak-izmenit-git-remote-url.
Для `git remote set-url origin <url>` у вас есть сокращенная команда: `remote <url>`.

Для создания модуля, не отходя от командной строки, наберите `create <owner> <repo_name>`, где <owner> - имя аккаунта или название организации в github, <repo_name> - название будущего модуля.