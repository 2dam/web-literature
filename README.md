# 문장

누구나 자유롭게 단편과 연재 소설을 올리고 읽는 웹앱 시제품입니다.

## Google 로그인 설정

로그인은 Supabase Auth의 Google OAuth만 사용합니다. 이메일/비밀번호 로그인은 제공하지 않습니다.

1. Supabase 프로젝트를 만들고 Authentication → Providers에서 Google을 활성화합니다.
2. Google Cloud Console에서 OAuth 웹 클라이언트를 만들고 승인된 리디렉션 URI에 Supabase가 안내하는 콜백 주소를 등록합니다.
3. Supabase의 Google provider 설정에 Google Client ID와 Client Secret을 입력합니다.
4. Supabase Authentication → URL Configuration에서 앱의 사이트 URL과 허용 리디렉션 URL을 설정합니다. 로컬에서는 `http://localhost:PORT`를 사용합니다. `file://`로 연 페이지에서는 OAuth 리디렉션을 사용할 수 없습니다.
5. Google Client ID와 Client Secret은 Supabase의 Google provider 설정 화면에만 입력합니다. 앱 코드나 채팅에는 넣지 마세요.
6. Supabase 프로젝트 URL과 publishable anon key를 `.gitignore` 처리된 `auth-config.local.js`의 `supabaseUrl`, `supabaseAnonKey`에 입력합니다. 이 브라우저 설정에는 Google Client Secret을 넣지 않습니다.
7. `index.html`을 로컬 웹 서버나 정적 호스팅으로 열고 Google 로그인을 확인합니다.

## Supabase에 작품 저장하기

1. Supabase Dashboard의 **SQL Editor**에서 [supabase-schema.sql](supabase-schema.sql)의 전체 내용을 한 번 실행합니다. 작품/회차 테이블과 비공개 `covers` Storage 버킷, Row Level Security 정책이 만들어집니다.
2. 앱을 `http://localhost` 또는 배포된 HTTPS 주소에서 엽니다. `file://` 주소는 로그인과 서버 저장에 사용할 수 없습니다.
3. Google 로그인하면 현재 브라우저에 로그인한 계정 소유로 저장된 작품·회차가 Supabase로 이전됩니다. 기존 브라우저 저장소도 백업으로 유지합니다.
4. 이후 작품 생성·수정, 회차 임시 저장·발행은 브라우저와 Supabase 양쪽에 저장됩니다. 로그아웃하거나 다른 기기에서 로그인해도 서버의 작품을 불러옵니다.

표지는 Supabase Storage의 비공개 버킷에 저장합니다. 작품이 공개 회차를 갖기 전에는 작가만 표지를 볼 수 있고, 공개된 작품의 표지는 독자에게 서명 URL로 제공됩니다. SQL 스키마를 실행하기 전에는 서버 저장이 되지 않으며, 앱은 이 경우 브라우저 저장본을 유지하고 오류를 안내합니다.

이전 작업 후에도 브라우저 저장본을 즉시 지우지 마세요. 데이터베이스 백업은 Supabase 플랜에 따라 다르므로, 중요한 원고는 별도 파일로도 보관하세요.

`auth-config.local.js`는 Git에 올라가지 않습니다. Supabase service-role key나 Google Client Secret을 프런트엔드에 넣지 마세요. Google Client Secret은 Supabase 대시보드에만 입력합니다.

좋아요, 북마크, 신고는 현재 브라우저 로컬 저장소 기반입니다. 작품과 회차는 위 SQL 스키마를 적용하면 Supabase에 저장됩니다. 관리자 숨김은 서버 검증된 관리자 역할이 아직 필요합니다.

