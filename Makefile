.PHONY: preview build check

preview:
	./scripts/zola serve --drafts

build:
	./scripts/zola build

check:
	./scripts/zola check --skip-external-links
