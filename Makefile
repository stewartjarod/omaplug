PREFIX ?= /usr
DESTDIR ?=

install:
	install -Dm755 omarket $(DESTDIR)$(PREFIX)/bin/omarket
	install -Dm644 SKILL.md $(DESTDIR)$(PREFIX)/share/omarket/SKILL.md
	install -Dm644 LICENSE $(DESTDIR)$(PREFIX)/share/licenses/omarket/LICENSE

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/omarket
	rm -rf $(DESTDIR)$(PREFIX)/share/omarket $(DESTDIR)$(PREFIX)/share/licenses/omarket

.PHONY: install uninstall
