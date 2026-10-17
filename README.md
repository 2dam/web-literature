# 문장

누구나 자유롭게 단편과 연재 소설을 올리고 읽는 웹앱 시제품입니다.

## Google 로그인 설정

로그인은 Supabase Auth의 Google OAuth만 사용합니다. 이메일/비밀번호 로그인은 제공하지 않습니다.

1. Supabase 프로젝트를 만들고 Authentication → Providers에서 Google을 활성화합니다.
2. Google Cloud Console에서 OAuth 웹 클라이언트를 만들고 승인된 리디렉션 URI에 Supabase가 안내하는 콜백 주소를 등록합니다.
3. Supabase의 Google provider 설정에 Google Client ID와 Client Secret을 입력합니다.
4. Supabase Authentication → URL Configuration에서 앱의 사이트 URL과 허용 리디렉션 URL을 설정합니다. 로컬에서는 `http://localhost:PORT`를 사용합니다. `file://`로 연 페이지에서는 OAuth 리디렉션을 사용할 수 없습니다.
5. Supabase 프로젝트 URL과 publishable anon key를 `auth-config.js`의 `supabaseUrl`, `supabaseAnonKey`에 입력합니다.
6. `index.html`을 로컬 웹 서버나 정적 호스팅으로 열고 Google 로그인을 확인합니다.

`auth-config.js`에는 브라우저 공개용 URL과 anon key만 입력합니다. Supabase service-role key나 Google Client Secret을 프런트엔드에 넣지 마세요. Client Secret은 Supabase 대시보드에만 입력합니다.

현재 작품, 회차, 좋아요, 신고 데이터는 브라우저 로컬 저장소에 남는 시제품입니다. 실제 다중 사용자 서비스와 관리자 조치를 위해서는 Supabase 데이터베이스, Row Level Security 정책, 서버 검증된 관리자 역할을 추가해야 합니다.

