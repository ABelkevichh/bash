#!/bin/bash

URL="git@github.com:ABelkevichh/bash.git"
REPO_CLONE="/mnt/g/belhard/bash/clone_git"

# Очистка и клонирование
rm -rf "$REPO_CLONE"
git clone "$URL" "$REPO_CLONE" || { echo "Ошибка клонирования"; exit 1; }
cd "$REPO_CLONE" || { echo "Не удалось перейти в $REPO_CLONE"; exit 1; }

# Извлечение X.Y.Z из тега
extract_version() {
	echo "$1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
}

# Получаем и фильтруем теги
VERSIONS=()
while read -r tag; do
	ver=$(extract_version "$tag")
	[ -n "$ver" ] && VERSIONS+=("$ver")
done <<< "$(git tag --list)"

# Если теги отсутствуют — создаём начальный
if [ ${#VERSIONS[@]} -eq 0 ]; then
	INITIAL_TAG="v0.0.0"
	echo "Теги не найдены. Создаю $INITIAL_TAG"
	git tag -a "$INITIAL_TAG" -m "Initial tag"
	git push origin "$INITIAL_TAG"
	rm -rf "$REPO_CLONE"
	exit 0
fi

# Определяем максимальную версию
OLD_IFS=$IFS
IFS=$'\n' sorted=($(sort -V <<<"${VERSIONS[*]}"))
IFS=$OLD_IFS
MAX_VERSION="${sorted[-1]}"
FULL_TAG=$(git tag --list | grep "$MAX_VERSION" | tail -n 1)

echo "Последний тег: $FULL_TAG"

# Проверяем наличие новых коммитов
COMMITS_AFTER_TAG=$(git log "$FULL_TAG"..HEAD --oneline)
if [ -z "$COMMITS_AFTER_TAG" ]; then
	echo "Нет новых коммитов с момента $FULL_TAG"
	rm -rf "$REPO_CLONE"
	exit 0
fi

# Увеличиваем версию (patch)
increment_patch() {
	IFS="." read -r major minor patch <<< "$1"
	patch=$((patch + 1))
	echo "$major.$minor.$patch"
}

NEW_VERSION=$(increment_patch "$MAX_VERSION")
NEW_TAG="v$NEW_VERSION"

echo "Создаём и пушим новый тег: $NEW_TAG"
git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
if git push origin "$NEW_TAG"; then
	echo "Тег $NEW_TAG успешно запушен"
else
	echo "Ошибка при пуше тега"
	rm -rf "$REPO_CLONE"
	exit 1
fi

rm -rf "$REPO_CLONE"


