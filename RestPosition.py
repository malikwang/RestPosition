#coding=utf-8
from __future__ import division
from bs4 import BeautifulSoup
import os
import xmlformatter
import sys 
reload(sys) 
sys.setdefaultencoding( "utf-8" ) 

def get_x_list(file_name):
	file_path = os.path.join(dir_path, file_name)
	file = open(file_path, 'r')
	line_list = file.readlines()
	x_list = []
	for line in line_list:
		elements = line.split(' ')
		if len(elements) == 3:
			x = elements[2].replace('\n', '')
			x = x.replace('x:', '')
			x_list.append(x)
	return x_list


def add_default_x(file_name):
	print('正在处理：%s'%file_name)
	file_path = os.path.join(dir_path, file_name)
	file_soup = BeautifulSoup(open(file_path),"lxml")
	note_list = file_soup.find_all('note')
	rest_list = []
	for note in note_list:
		if str(note).find('rest') != -1:
			rest_list.append(note)	
	# sort_rest_list = []
	# for rest in rest_list:
		# voice = int(rest.find('voice').string)
		# if voice == 2:
		# 	print('\t多声部')
		# 	return
	x_list = get_x_list(file_name.replace('.xml', '.txt'))
	if len(x_list) == len(rest_list):
		index = 0
		for rest in rest_list:
			rest['default-x'] = x_list[index]
			index += 1
		save_path = os.path.join(save_dir_path, file_name)
		new_file = open(save_path,'w')
		formatter = xmlformatter.Formatter()
		new_file.write(formatter.format_string(file_soup.prettify()))
		new_file.close()
	else:
		print('\t多Staff')

dir_path = '/Users/lisimin/Desktop/xml'
save_dir_path = '/Users/lisimin/Desktop/newxml'
xml_list = os.listdir(dir_path)
for xml in xml_list:
	if '.xml' in xml:
		add_default_x(xml)
