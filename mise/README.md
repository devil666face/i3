### All devs

```bash
mise install
mise cache clear
```

### Pip devs

```bash
pip install --no-cache-dir --upgrade -r requirements.txt
pip cache purge
```

### Npm -g devs

```bash
npm install -g . --cache /dev/null --loglevel=error
npm cache clean --force
```

### Golang devs

```bash
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/nametake/golangci-lint-langserver@latest
go install github.com/a-h/templ/cmd/templ@latest
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.6.2
```
