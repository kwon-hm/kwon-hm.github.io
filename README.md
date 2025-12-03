# About me

## 설치 및 실행 방법

### Ruby/Jekyll 환경 설정

#### 1. Ruby 설치

```bash
# rbenv를 사용하여 Ruby 3.2.2 설치
rbenv install 3.2.2
rbenv local 3.2.2
```

#### 2. 의존성 설치

```bash
gem install bundler
bundle install
```

#### 3. 로컬 개발 서버 실행

```bash
bundle exec jekyll serve
```

브라우저에서 `http://localhost:4000` 접속하여 확인

#### 4. 빌드 (선택사항)

```bash
bundle exec jekyll build
```

빌드된 파일은 `_site/` 디렉터리에 생성됩니다.
