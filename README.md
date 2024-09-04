# tLanscoder

이 Ruby 스크립트는 FFmpeg를 사용해 다양한 형식으로 비디오 파일을 인코딩하고, MiniMagick을 사용해 이미지 파일을 처리합니다. 이 스크립트는 인텔, AMD, Nvidia의 하드웨어 가속을 지원하며, DNxHD, H.264, H.265 등의 포맷 옵션을 제공합니다. 또한, 다양한 이미지 형식 간 변환도 가능합니다.

## 기능

- DNxHD, H.264, H.265 포맷으로 비디오 인코딩.
- VAAPI(AMD) 및 NVENC(Nvidia)를 통한 하드웨어 가속 비디오 인코딩.
- 다양한 이미지 형식(JPG, PNG, GIF, TIFF 등) 간 변환.
- 실시간 진행 상황 및 완료 예상 시간 표시.

## 의존성

다음 소프트웨어가 설치되어 있어야 합니다:

**Ruby** (버전 2.5 이상)
```bash
   sudo pacman -S ruby
```

FFmpeg (비디오 인코딩을 위해 필요)

```bash

sudo pacman -S ffmpeg
```
ImageMagick (이미지 처리를 위해 필요)

```bash

sudo pacman -S imagemagick
```
mini_magick gem 설치:

```bash

    gem install mini_magick
```

## 설치 방법

    이 레포지토리를 클론하세요:

 ```bash

    git clone https://github.com/yourusername/your-repo-name.git
    cd your-repo-name
```
    위의 필요 조건에 따라 필요한 라이브러리를 설치하세요.

## 사용 방법

이 스크립트는 여러 포맷으로 비디오를 인코딩하거나 이미지 파일을 변환하는 데 사용됩니다.

### 비디오 인코딩

비디오 파일을 인코딩하려면 인코딩 포맷 옵션(-dnxhd, -h264, -h265)을 지정하고 비디오 파일이 있는 디렉터리를 제공합니다.

예를 들어, H.264 형식으로 인코딩하려면:

```bash

ruby script_name.rb -h264
```


지원되는 형식:

    -dnxhd (CPU 기반 DNxHD 인코딩)
    -dnxhdR (AMD VAAPI 기반 DNxHD 인코딩)
    -dnxhdG (Nvidia NVENC 기반 DNxHD 인코딩)
    -h264 (CPU 기반 H.264 인코딩)
    -h264R (AMD VAAPI 기반 H.264 인코딩)
    -h264G (Nvidia NVENC 기반 H.264 인코딩)
    -h265 (CPU 기반 H.265 인코딩)
    -h265R (AMD VAAPI 기반 H.265 인코딩)
    -h265G (Nvidia NVENC 기반 H.265 인코딩)
    -wav (오디오 파일 추출)

### 이미지 변환

이미지를 변환하려면 -image 옵션과 원하는 출력 형식(e.g., jpg, png, gif)을 입력하세요:

```bash

ruby script_name.rb -image jpg
```
스크립트는 현재 디렉터리에서 이미지를 찾아 지정한 형식으로 변환합니다.

지원되는 입력 형식: jpg, png, gif, webp, tiff, bmp, heic


# 출력

변환된 비디오 및 이미지 파일은 자동으로 생성되는 ./transcoded/ 디렉터리에 저장됩니다.
예제 명령어

    비디오를 H.264로 CPU 기반 인코딩:

```bash

ruby script_name.rb -h264
```
이미지를 PNG 형식으로 변환:

```bash

ruby script_name.rb -image png
```
비디오를 Nvidia GPU 기반 DNxHD로 인코딩:

```bash

    ruby script_name.rb -dnxhdG
```


# 실시간 진행 상황

스크립트는 비디오 인코딩 중 실시간으로 진행 상황을 제공합니다
