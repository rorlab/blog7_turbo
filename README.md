# Blog with Tubo, Rails 7

## RORLAB BIWEEKLY TOPIC LECTURE #1
### HOTWIRE#1 - TURBO

Live Coding ...

로컬 서버 시작
```bash
$ bin/rails server
```


# HOTWIRE #1 (Turbo)

: 이 문서는 2023년 7월 24일 개최된 RORLAB Biweekly Topic Lecture 중 진행되었던 Live Coding 교재입니다.



## blog 프로젝트 생성

```bash
$ rails new blog7_turbo && cd blog7_turbo
```

## 홈 페이지 생성

```bash
$ bin/rails g controller pages home
```

## 루트페이지 정의

```ruby
# config/routes.rb
root "pages#home"
```

## about 액션 추가

```ruby
# app/controllers/pages_controller.rb
def about
end
```

## about 템플릿 파일 생성

```erb
<!-- app/views/pages/about.html.erb -->
<h1>Pages#about</h1>
<p>Find me in app/views/pages/about.html.erb</p>

<%= link_to "Root", root_path %>
```

## about 라우트 추가

```ruby
# config/routes.rb
get 'about', to: 'pages#about'
```

### home 템플릿 파일 about 경로 링크 추가

```erb
<h1>Pages#home</h1>
<p>Find me in app/views/pages/home.html.erb</p>

<%= link_to 'About', '/about' %>
```

> `Turbo Drive` 작동 확인

## Turbo progress bar

#### : 로딩 시간이 500ms 이상 소요될 때 보임

- https://turbo.hotwired.dev/handbook/drive#displaying-progress
- https://turbo.hotwired.dev/reference/drive#turbodrivesetprogressbardelay

```css
.turbo-progress-bar {
  height: 1rem;
  background-color: rgb(162, 246, 255);
  /* visibility: hidden; */
}
```



## Turbo Frame

`home` 템플릿에서 <turbo-frame> 태그로 링크를 wrapping

```erb
<h1>Pages#home</h1>
<p>Find me in app/views/pages/home.html.erb</p>

<%= turbo_frame_tag :nav do %>
  <%= link_to 'About', '/about' %>
<% end %>
```

이 상태에서 about 링크를 클릭하면 `Content missing` 표시됨

이유는 about 템플릿에서 <turbo-frame id='nav'></turbo-frame> 에 해당하는 content 가 없기 때문.

>조치사항:
>`about` 템플릿에서 <turbo-frame> 태그로 링크를 wrapping
>
>```erb
><h1>Pages#about</h1>
><p>Find me in app/views/pages/about.html.erb</p>
>
><%= turbo_frame_tag :nav do %>
>  <%= link_to "Root", root_path %>
><% end %>
>```

이제 `<%= link_to "Root", root_path %>` 가 content 로 표시됨



## Turbo Stream

```ruby
# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def home
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('nav', partial: 'pages/home')
      end
    end    
  end

  def about
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('nav', partial: 'pages/about')
      end
    end
  end
end
```



## Partial 템플릿 추가

```erb
<!-- app/views/pages/_home.html.erb -->
<%= link_to 'About', '/about', data: { turbo_stream: true } %>
```

```erb
<!-- app/views/pages/_about.html.erb -->
<%= link_to 'Root', root_path, data: { turbo_stream: true } %>
```

home 액션 turbo stream 렌더링

```ruby
# app/controllers/pages_controller.rb
def home
  respond_to do |format|
    format.html
    format.turbo_stream do
      render turbo_stream: turbo_stream.update('nav', partial: 'pages/home')
    end
  end    
end
```
렌더링 결과

```html
<turbo-stream action="update" target="nav">
  <template>
    <a data-turbo-stream="true" href="/">Root</a>
  </template>
</turbo-stream>
```

about 액션 turbo stream 렌더링

```ruby
# app/controller/pages_controller.rb
def about
  respond_to do |format|
    format.html
    format.turbo_stream do
      render turbo_stream: turbo_stream.update('nav', partial: 'pages/about')
    end
  end
end
```
렌더링 결과
```html
<turbo-stream action="update" target="nav">
  <template>
    <a data-turbo-stream="true" href="/about">About</a>
  </template>
</turbo-stream>
```



## Post 리소스 scaffolding

```bash
$ bin/rails g scaffold Post title:string body:text
```

### Turbo Frame

```erb
<!-- app/views/posts/index.html.erb
<%= turbo_frame_tag Post.new do %>
  <%= link_to "New post", new_post_path %>
<% end %>
```

```erb
<!-- app/views/posts/new.html.erb
<%= turbo_frame_tag @post do %>
  <%= render "form", post: @post %>
<% end %>
```

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def turbo_frame_requested?
    request.headers["Turbo-Frame"]
  end
end
```

```erb
<!-- app/views/posts/_form.html.erb -->
<div>
  <%= form.submit %>
  <%= link_to "Close Form", '#' if turbo_frame_requested? %>
</div>
```

### Turbo Stream

```ruby
# app/controllers/posts_controller.rb
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream # 추가
      format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
      format.json { render :show, status: :created, location: @post }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @post.errors, status: :unprocessable_entity }
    end
  end
end
```

```erb
<!-- app/views/posts/create.html.erb -->
<%= turbo_stream.update :new_post do %>
  <%= link_to "New post", new_post_path %>
<% end %>

<%= turbo_stream.prepend :posts do %>
  <%= render @post %>
<% end %>
```

### Turbo Frame for Edit Link in show template

```erb
<!-- app/views/posts/show.html.rb -->
<p style="color: green"><%= notice %></p>

<%= turbo_frame_tag @post do %>
  <%= render @post %>
<% end %>

<div>
  <%= link_to "Edit this post", edit_post_path(@post), data: { turbo_frame: dom_id(@post) } %> |
  <%= link_to "Back to posts", posts_path %>

  <%= button_to "Destroy this post", @post, method: :delete %>
</div>
```
### Turbo Frame wrapping for Edit template

```erb
<!-- app/views/posts/edit.html.erb -->
<h1>Editing post</h1>

<%= turbo_frame_tag @post do %>
  <%= render "form", post: @post %>
<% end %>

<br>

<div>
  <%= link_to "Show this post", @post %> |
  <%= link_to "Back to posts", posts_path %>
</div>
```

### Turbo Stream Render for Posts#Destroy

```ruby
# app/controllers/pages_controller.rb
def destroy
  @post.destroy

  respond_to do |format|
    format.turbo_stream { render turbo_stream: turbo_stream.remove(@post) }
    format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
    format.json { head :no_content }
  end
end
```

```erb
<!-- app/views/posts/index.html.erb -->
<p style="color: green"><%= notice %></p>

<h1>Posts</h1>

<%= turbo_frame_tag Post.new do %>
  <%= link_to "New post", new_post_path %>
<% end %>

<div id="posts">
  <% @posts.each do |post| %>
    <%= render post %>
    <p>
      <%= link_to "Show this post", post %> |
      <%= link_to "Destroy this post", post, data: { turbo_method: :delete, turbo_confirm: 'Are you sure?' } %>
    </p>
  <% end %>
</div>
```

삭제를 위해서 15번 코드라인을 추가한다.  그러나 실제로 삭제 링크를 클릭했을 때 13, 14, 15, 16 코드라인이 그대로 남아 있게 되어 위치를 아래와 같이 _post.html.erb 파일로 이동한다.

```erb
<!-- app/views/posts/_post.html.erb -->
<div id="<%= dom_id post %>">
  <p>
    <strong>Title:</strong>
    <%= post.title %>
  </p>

  <p>
    <strong>Content:</strong>
    <%= post.content %>
  </p>

  <p>
    <%= link_to "Show this post", post %> |
    <%= link_to "Destroy this post", post, data: { turbo_method: :delete, turbo_confirm: 'Are you sure?' } %>
  </p>

</div>
```



## Animation 추가

참고 문서:

- https://edforshaw.co.uk/hotwire-turbo-stream-animations

다운로드: animate.css

- https://github.com/animate-css/animate.css/blob/main/animate.css

```js
// app/javascript/application.js
document.addEventListener("turbo:before-stream-render", (event) => {
  const action = event.target.action;
  const targetFrame = document.getElementById(event.target.target);
  if (action === "remove") {
    let streamExitClass = targetFrame.dataset.animateOut;
    if (streamExitClass) {
      event.preventDefault();
      targetFrame.classList.add(streamExitClass);
      targetFrame.addEventListener("animationend", function () {
        event.target.performAction();
      });
    }
  } else if (action === "prepend" || action === "append") {
    if (event.target.firstElementChild instanceof HTMLTemplateElement) {
      let enterAnimationClass =
        event.target.templateContent.firstElementChild.dataset.animateIn;
      if (enterAnimationClass) {
        event.target.templateElement.content.firstElementChild.classList.add(
          enterAnimationClass
        );
      }
    }
  }
});
```

여기까지 HOTWIRE TURBO의 기본 기능에 대해서 알아봤습니다.

감사합니다. 



2023-07-24

Lucius Choi, RORLAB
