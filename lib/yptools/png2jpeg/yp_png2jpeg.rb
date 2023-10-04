require 'colored'
require_relative '../log/yp_log'
require 'fileutils'

class YPPng2Jpeg
  def self.png2jpeg(target_folder)
    # 检查是否提供了目标文件夹名称作为参数
    if target_folder.nil? || target_folder.empty?
      puts '请提供目标文件夹名称作为参数'.red
      exit(1)
    end

    # 检查目标文件夹是否存在
    unless File.directory?(target_folder)
      puts "目标文件夹不存在：#{target_folder}".red
      exit(1)
    end

    # 创建新的文件夹（hah-jpeg）在同级目录下
    output_root_folder = File.join(File.dirname(target_folder), "#{File.basename(target_folder)}-jpeg")
    FileUtils.mkdir_p(output_root_folder)

    # 遍历目标文件夹中的所有PNG文件
    Dir.glob(File.join(target_folder, '**', '*.png')).each do |png_file|
      # 获取文件路径、文件名（不含路径）和扩展名
      file_path = File.dirname(png_file)
      filename = File.basename(png_file)
      extension = File.extname(filename)

      # 创建目标文件的路径和名称，将扩展名从PNG更改为JPG
      new_filename = File.basename(filename, '.*') + '.jpg'
      output_folder = File.join(output_root_folder, File.basename(file_path))
      FileUtils.mkdir_p(output_folder)
      new_file = File.join(output_folder, new_filename)

      # 使用sips命令将PNG转换为JPG
      system("sips -s format jpeg '#{png_file}' --out '#{new_file}'")

      # 输出转换结果
      puts "已将 #{png_file} 转换为 #{new_file}".green
    end

    puts "转换完成，JPEG文件保存在 #{output_root_folder} 中".green
  end
end