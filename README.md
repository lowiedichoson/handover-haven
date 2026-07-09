# 🚀 Handover Haven

**ICTG's team handover & turnover knowledge base** — a living document where
departing team members leave behind everything the next person needs to succeed.

Built with [MkDocs](https://www.mkdocs.org/) and the
[Shadcn theme](https://github.com/mimicji/mkdocs-shadcn).

## Quick Links

- 📖 [Browse the docs](https://github.com/lowiedichoson/handover-haven/tree/main/docs)
- 📝 [How to add your handover](docs/getting-started/how-to-use.md)
- 📋 [Handover template](docs/getting-started/template.md)
- 📚 [Glossary](docs/getting-started/glossary.md)

## Local Development

This project uses [uv](https://docs.astral.sh/uv/) for dependency management.

```bash
# Install dependencies
uv sync

# Serve locally with live reload
uv run mkdocs serve --livereload
```

Open `http://127.0.0.1:8000`.

> **Tip:** Use the `-a` flag to bind to a custom address and port:
> ```bash
> uv run mkdocs serve -a localhost:9999 --livereload
> ```

## Contributing

1. Fork this repo
2. Follow the [How to Use](docs/getting-started/how-to-use.md) guide
3. Open a PR

> "Don't let knowledge walk out the door."
