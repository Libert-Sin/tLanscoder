require 'fileutils'   # 파일 및 디렉터리 작업을 위한 모듈
require 'tempfile'    # 임시 파일 생성을 위한 모듈
require 'date'        # 날짜 및 시간 처리를 위한 모듈
require 'mini_magick' # 이미지 처리 라이브러리 MiniMagick

# FFMPEG 명령어와 출력 파일 경로를 생성하는 함수
def ffmpeg_command_and_output_file(input_file, input_directory, output_directory, option)
  ext = File.extname(input_file)  # 입력 파일의 확장자 추출
  relative_path = input_file.sub(input_directory, '').sub(/^\//, '') # 입력 디렉토리 기준 상대 경로 계산
  output_sub_directory = File.join(output_directory, File.dirname(relative_path)) # 출력 디렉터리 내 하위 폴더 유지
  FileUtils.mkdir_p(output_sub_directory) # 출력 디렉터리 하위 폴더 생성

  fps = get_video_fps(input_file)  # FPS 확인 함수 호출

  case option
  when '-dnxhd' # DNxHD 포맷 (CPU)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mov"
    command = "ffmpeg -i '#{input_file}' -vf 'format=yuv422p10le' -c:v dnxhd -profile:v dnxhr_hqx -c:a pcm_s24le -ac 2 -f mov '#{output_file}'"

  when '-dnxhd_proxy'  # DNxHD 프록시 포맷 (CPU)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mov"
    command = "ffmpeg -i '#{input_file}' -vf 'scale=-1:720,format=yuv422p10le' -c:v dnxhd -profile:v dnxhr_sq -c:a pcm_s24le -ac 2 -f mov '#{output_file}'"

  when '-dnxhdR'  # DNxHD 포맷 (라데온 GPU, VAAPI)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mov"
    command = "ffmpeg -hwaccel vaapi -i '#{input_file}' -vf 'format=yuv422p10le' -c:v dnxhd -profile:v dnxhr_hqx -c:a pcm_s24le -ac 2 -f mov '#{output_file}'"

  when '-dnxhdR_proxy'  # DNxHD 프록시 포맷 (라데온 GPU, VAAPI)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mov"
    command = "ffmpeg -hwaccel vaapi -i '#{input_file}' -vf 'scale=-1:720,format=yuv422p10le' -c:v dnxhd -profile:v dnxhr_sq -c:a pcm_s24le -ac 2 -f mov '#{output_file}'"

  when '-dnxhdG'  # DNxHD 포맷 (지포스 GPU, NVENC)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mov"
    command = "ffmpeg -hwaccel cuda -i '#{input_file}' -vf 'format=yuv422p10le' -c:v dnxhd -profile:v dnxhr_hqx -c:a pcm_s24le -ac 2 -f mov '#{output_file}'"

  when '-dnxhdG_proxy'  # DNxHD 프록시 포맷 (지포스 GPU, NVENC)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mov"
    command = "ffmpeg -hwaccel cuda -i '#{input_file}' -vf 'scale=-1:720,format=yuv422p10le' -c:v dnxhd -profile:v dnxhr_sq -c:a pcm_s24le -ac 2 -f mov '#{output_file}'"

  when '-h264' # H.264 포맷 (CPU)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mp4"
    command = "ffmpeg -i '#{input_file}' -c:v libx264 -preset fast -crf 23 '#{output_file}'"

  when '-h264_proxy' # H.264 프록시 포맷 (CPU)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mp4"
    command = "ffmpeg -i '#{input_file}' -vf scale=-1:720 -c:v libx264 -preset fast -crf 23 '#{output_file}'"

  when '-h264R' # H.264 포맷 (라데온 GPU, VAAPI)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mp4"
    command = "ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i '#{input_file}' -vf 'format=nv12,hwupload' -c:v h264_vaapi '#{output_file}'"

  when '-h264R_proxy' # H.264 프록시 포맷 (라데온 GPU, VAAPI)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mp4"
    command = "ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i '#{input_file}' -vf 'scale=-1:720,format=nv12,hwupload' -c:v h264_vaapi '#{output_file}'"

  when '-h264G' # H.264 포맷 (지포스 GPU, NVENC)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mp4"
    command = "ffmpeg -hwaccel cuda -i '#{input_file}' -c:v h264_nvenc -preset fast '#{output_file}'"

  when '-h264G_proxy' # H.264 프록시 포맷 (지포스 GPU, NVENC)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mp4"
    command = "ffmpeg -hwaccel cuda -i '#{input_file}' -vf scale=-1:720 -c:v h264_nvenc -preset fast '#{output_file}'"

  when '-h265'  # H.265 포맷 (CPU)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mp4"
    command = "ffmpeg -i '#{input_file}' -c:v libx265 -preset fast -crf 28 '#{output_file}'"

  when '-h265_proxy'  # H.265 프록시 포맷 (CPU)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mp4"
    command = "ffmpeg -i '#{input_file}' -vf scale=-1:720 -c:v libx265 -preset fast -crf 28 '#{output_file}'"

  when '-h265R'  # H.265 포맷 (라데온 GPU, VAAPI)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mp4"
    command = "ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i '#{input_file}' -vf 'format=nv12,hwupload' -c:v hevc_vaapi '#{output_file}'"

  when '-h265R_proxy'  # H.265 프록시 포맷 (라데온 GPU, VAAPI)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mp4"
    command = "ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i '#{input_file}' -vf 'scale=-1:720,format=nv12,hwupload' -c:v hevc_vaapi '#{output_file}'"

  when '-h265G'  # H.265 포맷 (지포스 GPU, NVENC)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.mp4"
    command = "ffmpeg -hwaccel cuda -i '#{input_file}' -c:v hevc_nvenc -preset fast '#{output_file}'"

  when '-h265G_proxy'  # H.265 프록시 포맷 (지포스 GPU, NVENC)
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}_proxy.mp4"
    command = "ffmpeg -hwaccel cuda -i '#{input_file}' -vf scale=-1:720 -c:v hevc_nvenc -preset fast '#{output_file}'"

  when '-wav' # WAV 오디오 파일 생성
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.wav"
    command = "ffmpeg -i '#{input_file}' -vn -acodec pcm_s24le -ar 48000 '#{output_file}'"

  else
    return [nil, nil]  # 잘못된 옵션 처리
  end

  [command, output_file, fps]  # FFMPEG 명령어와 출력 파일 경로 반환
end



# 디렉토리 내 모든 하위 폴더의 파일 찾기 함수
def find_files_in_directory(directory, extensions)
  puts("탐색할 디렉토리: #{directory}")
  files = []
  Dir.entries(directory).each do |entry|
    next if ['.', '..'].include?(entry)  # 현재 디렉토리와 상위 디렉토리 제외
    full_path = File.join(directory, entry)
    if File.file?(full_path) && extensions.include?(File.extname(entry).delete('.').downcase)
      files << full_path
    end
  end
  if files.empty?
    puts("경고: #{directory}에서 파일을 찾을 수 없습니다.")
  else
    puts("찾은 파일: #{files.size} 개")
  end
  files
end






# 전역 변수 초기화
$total_video_duration = 0.0  # 전체 영상 파일들의 총 길이
$current_video_duration_sum = 0.0  # 현재까지 처리된 영상들의 길이 합계
$total_start_time = Time.now  # 전체 작업의 시작 시간
$total_elapsed_time = 0  # 총 경과 시간
$total_remaining_time = 0  # 남은 예상 작업 시간
$total_complete_time = Time.now  # 작업 완료 예상 시간
$video_durations = []  # 각 영상 파일의 길이를 저장하는 배열



# 시간을 '시:분:초' 형식으로 변환하는 함수
def format_duration(seconds)
  hours = seconds / 3600  # 시 계산
  minutes = (seconds / 60) % 60  # 분 계산
  seconds = seconds % 60  # 초 계산
  format("%02d:%02d:%02d", hours, minutes, seconds)  # '시:분:초' 형식 반환
end

# 영상의 FPS 정보를 추출하는 함수
def get_video_fps(input_file)
  ffprobe_cmd = "ffprobe -v 0 -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 '#{input_file}'"
  fps_info = `#{ffprobe_cmd}`.strip
  if fps_info.empty?
    puts("경고: #{input_file}의 FPS 정보를 가져올 수 없습니다. 기본값(30fps) 사용")
    return 30.0
  end
  numerator, denominator = fps_info.split('/').map(&:to_f)
  fps = (denominator != 0) ? (numerator / denominator) : 0
  fps.round(2)
end



# 영상 파일들의 총 길이 계산 및 각 파일 길이 저장
def calculate_total_video_duration(video_files)
  puts("|| 영상 파일 스캔 중 ||")
  video_files.each do |file|
    ffprobe_duration_cmd = "ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 '#{file}'"
    puts("Processing file: #{file}")  # 현재 처리 중인 파일 출력
    duration_output = `#{ffprobe_duration_cmd}`
    puts("ffprobe 결과: #{duration_output.strip.inspect}")  # ffprobe 결과 출력
    duration = duration_output.to_f
    if duration == 0.0
      puts("경고: #{file}의 길이를 가져올 수 없습니다.")
    else
      $total_video_duration += duration
      $video_durations << duration
    end
  end
  puts("|| 영상 파일 스캔 완료 ||")
  total_video_duration_str = Time.at($total_video_duration).utc.strftime("%H:%M:%S")
  puts("총 영상 길이: #{total_video_duration_str}")
end




# FFMPEG 명령어 실행 및 진행률 추적 함수
def encode_video(ffmpeg_cmd, video_duration, total_duration, log_file, total_files, current_index, fps)
  video_duration ||= 0.0
  start_time = Time.now
  pid = spawn("#{ffmpeg_cmd} 2> #{log_file.path}") # FFMPEG 프로세스 실행
  log_file.rewind
  while Process.waitpid(pid, Process::WNOHANG).nil?
    sleep 1
    log_file_lines = log_file.readlines
    unless log_file_lines.empty?
      last_line = log_file_lines.last
      if last_line =~ /time=\s*(\d+:\d+:\d+\.\d+)/
        current_time_str = $1 || "00:00:00.00"
        current_time = DateTime.parse(current_time_str).to_time
        start_time_of_video = DateTime.parse("00:00:00.00").to_time
        elapsed_video_time = (current_time - start_time_of_video).to_f
        $current_video_duration_sum = elapsed_video_time + $video_durations[0...(current_index-1)].sum
        percent_complete = (elapsed_video_time / video_duration * 100).round(2)
        progress_str = sprintf("%.2f%%", percent_complete)

        elapsed_time_str = format_duration(elapsed_video_time)
        $total_elapsed_time = Time.now - $total_start_time
        average_speed = ($current_video_duration_sum > 0 && $total_elapsed_time > 0) ? ($current_video_duration_sum / $total_elapsed_time) : 0
        remaining_videos_duration = $total_video_duration - $current_video_duration_sum
        $total_remaining_time = (average_speed > 0) ? (remaining_videos_duration / average_speed) : 0
        $total_complete_time = Time.now + $total_remaining_time

        remaining_time = video_duration - elapsed_video_time
        complete_time = (average_speed > 0) ? (Time.now + remaining_time / average_speed) : Time.now

        # 출력 전에 모든 값이 유효한지 확인
        total_elapsed_str = format_duration($total_elapsed_time)
        total_remaining_str = format_duration($total_remaining_time)
        total_complete_str = $total_complete_time.strftime("%m/%d %H:%M:%S")


        print "\e[4A"
        print "\e[J"

        printf("\n|| 전체 작업 || %d/%d\t경과시간: %s\t남은시간: %s\t 완료시각: %s\n",
               current_index, total_files, total_elapsed_str, total_remaining_str, total_complete_str)
        printf("|| 현재 작업 || %s\t작업구간: %s\t남은구간: %s\t 완료시각: %s\n",
               progress_str, elapsed_time_str, format_duration(remaining_time), complete_time.strftime("%m/%d %H:%M:%S"))
        printf("   평균 작업 속도 : %.2fs/s (%.2ffps)\n", average_speed, average_speed*fps)
      end
    end
  end
end



# 이미지 파일 처리 함수
def process_images(image_files, output_directory, format)
  total_files = image_files.length  # 총 이미지 파일 수

  if total_files == 0
    puts "변환할 이미지 파일이 없습니다."
    return
  end

  puts "|| 이미지 변환 작업 시작 ||"
  image_files.each_with_index do |input_file, index|
    ext = File.extname(input_file).downcase  # 확장자를 소문자로 통일
    relative_path = input_file.sub(Dir.pwd, '').sub(/^\//, '') # 입력 디렉터리 기준 상대 경로 계산
    output_sub_directory = File.join(output_directory, File.dirname(relative_path)) # 출력 디렉터리 내 하위 폴더 유지
    FileUtils.mkdir_p(output_sub_directory) # 하위 폴더 생성

    # 입력 파일과 출력 파일 설정
    output_file = "#{output_sub_directory}/#{File.basename(input_file, ext)}.#{format}"  # 변환 후 파일명 설정

    # MiniMagick를 사용하여 이미지 변환
    begin
      image = MiniMagick::Image.open(input_file)
      image.format(format)  # 원하는 포맷으로 변환
      image.write(output_file)  # 변환된 이미지를 저장
      puts "변환 성공: #{output_file} (#{index + 1}/#{total_files})"
    rescue => e
      puts "변환 실패: #{input_file} (오류: #{e.message})"
    end
  end
  puts "|| 이미지 변환 작업 완료 ||"
end





# 메인 로직
input_directory = Dir.pwd  # 현재 작업 디렉토리
output_directory = File.join(input_directory, "transcoded/")  # 출력 디렉토리
FileUtils.mkdir_p(output_directory)  # 출력 디렉토리 생성

option = ARGV[0]  # 첫 번째 인자로 옵션 가져오기
format = ARGV[1]  # 이미지 변환일 경우 두 번째 인자로 이미지 포맷 가져오기

# 비디오 및 이미지 확장자 목록
video_extensions = %w[mp4 mov avi mkv mxf rsv]
image_extensions = %w[jpg png gif webp tiff bmp heic]

if option.nil?
  puts <<-USAGE
  사용법: ruby tLanscoder.rb [옵션] [이미지 포맷(이미지 변환 시)]

  비디오 변환 옵션:
  CPU 사용 옵션:
  -dnxhd         : DNxHD 포맷으로 변환
  -h264          : H.264 포맷으로 변환
  -h265          : H.265 포맷으로 변환
  -dnxhd_proxy   : DNxHD 프록시 포맷으로 변환 (720p)
  -h264_proxy    : H.264 프록시 포맷으로 변환 (720p)
  -h265_proxy    : H.265 프록시 포맷으로 변환 (720p)
  라데온 GPU 사용 옵션 (VAAPI):
  -dnxhdR        : DNxHD 포맷으로 변환
  -h264R         : H.264 포맷으로 변환
  -h265R         : H.265 포맷으로 변환
  -dnxhdR_proxy  : DNxHD 프록시 포맷으로 변환 (720p)
  -h264R_proxy   : H.264 프록시 포맷으로 변환 (720p)
  -h265R_proxy   : H.265 프록시 포맷으로 변환 (720p)
  지포스 GPU 사용 옵션 (NVENC):
  -dnxhdG        : DNxHD 포맷으로 변환
  -h264G         : H.264 포맷으로 변환
  -h265G         : H.265 포맷으로 변환
  -dnxhdG_proxy  : DNxHD 프록시 포맷으로 변환 (720p)
  -h264G_proxy   : H.264 프록시 포맷으로 변환 (720p)
  -h265G_proxy   : H.265 프록시 포맷으로 변환 (720p)

  오디오 추출 옵션:
  -wav           : WAV 오디오 파일 추출

  이미지 변환 옵션:
  -image [포맷]  : 이미지를 지정된 포맷으로 변환 (예: jpg, png, webp)

  예시:
  비디오 변환: ruby tLanscoder.rb -h264
  이미지 변환: ruby tLanscoder.rb -image jpg

  참고:
  - 입력 파일은 현재 디렉토리와 모든 하위 디렉토리에서 자동으로 검색됩니다.
  - 출력 파일은 './transcoded/' 디렉토리에 원본 파일 구조를 유지하며 저장됩니다.
  - GPU 옵션을 사용할 때는 해당 하드웨어와 드라이버가 설치되어 있어야 합니다.
  USAGE
else
  if option == '-image'
    image_files = find_files_in_directory(input_directory, image_extensions) # 이미지 파일 목록 가져오기
    process_images(image_files, output_directory, format)  # 이미지 변환 처리
  else
    video_files = find_files_in_directory(input_directory, video_extensions) # 영상 파일 목록 가져오기
    calculate_total_video_duration(video_files)  # 총 영상 길이 계산
    total_files = video_files.length  # 총 영상 파일 수

    video_files.each_with_index do |input_file, index|
      current_index = index + 1  # 현재 파일 인덱스
      ffmpeg_cmd, output_file, fps = ffmpeg_command_and_output_file(input_file, input_directory, output_directory, option)  # FFMPEG 명령어와 FPS 생성
      next if ffmpeg_cmd.nil?  # 명령어가 없으면 다음 파일로 이동

      log_file = Tempfile.new('ffmpeg_log')  # 임시 로그 파일 생성
      encode_video(ffmpeg_cmd, $video_durations[index], $total_video_duration, log_file, total_files, current_index, fps)
      log_file.close
      log_file.unlink
    end
  end
end
