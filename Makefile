PREFIX ?= /usr
DESTDIR ?=

install:
	install -Dm755 omaplug $(DESTDIR)$(PREFIX)/bin/omaplug
	install -Dm644 SKILL.md $(DESTDIR)$(PREFIX)/share/omaplug/SKILL.md
	install -Dm644 LICENSE $(DESTDIR)$(PREFIX)/share/licenses/omaplug/LICENSE

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/omaplug
	rm -rf $(DESTDIR)$(PREFIX)/share/omaplug $(DESTDIR)$(PREFIX)/share/licenses/omaplug

.PHONY: install uninstall
