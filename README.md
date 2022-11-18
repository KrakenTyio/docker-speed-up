
# Documentation

### Demo page

```bash
## install deps
make setup
make install

## run demo page on http://0.0.0.0:8081
make dev
```

### Build development
```bash
make build
```

### Build release
```bash
make release
```
### Unit testing
```bash
make tests
```
```bash
## development unit tests
make testdev
```

### E2e testing
```bash
make e2etest
```


### DeInit submodules for not always update submodule ref
```bash
make clean

## you need to be in source folder
## deinit core from
git submodule deinit core

## or remove all submodule no matter on name
git submodule deinit --all
```

### Generate new modernizr (optional)
```bash
npm run modernizr
```

## Build image
```bash
docker build -f Dockerfile -t bartsk/node-fibers-user-chmod:${version} -t bartsk/node-fibers-user-chmod:latest .
docker build -f Dockerfile-full -t bartsk/node-fibers-user-chmod:${version}-full .
```

## Publish to dockerhub
```bash
docker push bartsk/node-fibers-user-chmod:${version}
docker push bartsk/node-fibers-user-chmod:${version}-full
docker push bartsk/node-fibers-user-chmod:latest
```
