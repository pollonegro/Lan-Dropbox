#!/usr/bin/env python
import shodan
import re
import socket
import os, sys
import requests
import urllib2
import dns.resolver
import dns.resolver
import xlsxwriter
from time import sleep
import argparse     

api_key = 'TrJLuBlD3vfXGPXYBF8CGYTXuweS6hat'
hostnames3 = ''
puertosLimpios3 = ''

parser = argparse.ArgumentParser(description='Version: 1 - This script intend to obtain information with Shodan')
parser.add_argument('-t','--target', help="Indicate ip/domain to process \n\n",required=False)
parser.add_argument('-f','--file', help='Indicate ip list file to process\n\n', required=False)
parser.add_argument('-s','--silent', help="Dont show nothing in screen \n\n",required=False, action='store_true')
parser.add_argument('-a','--api', help="Set a custom Shodan API key \n\n",required=False)
parser.add_argument('-ex','--exportXLS', help='Export the results to a XLSX file\n\n', required=False)
args = parser.parse_args()

if args.exportXLS is not None:
    fileoutXLS = xlsxwriter.Workbook(args.exportXLS + '.xlsx')  
    fileout_sheet = fileoutXLS.add_worksheet()
    bold = fileoutXLS.add_format({'bold': True})
    fileout_sheet.write(0, 0, 'IP', bold)
    fileout_sheet.write(0, 1, 'ISP', bold)
    fileout_sheet.write(0, 2, 'ASN', bold)
    fileout_sheet.write(0, 3, 'LOCATION', bold)
    fileout_sheet.write(0, 4, 'PORTS', bold)
    fileout_sheet.write(0, 5, 'UPDATED', bold)
    contador = 1

if args.api is not None:
    api_key = args.api

api = shodan.Shodan(api_key)

def formatParams (results):

    global hostnames3
    global puertosLimpios3

    #Format parameters
    hostnames1 =  str(results.get('hostnames')).replace("', u'", " | ")
    hostnames2 =  hostnames1.replace("[u'", "")
    hostnames3 =  hostnames2.replace("']", "")
    puertosLimpios =  str(results['ports']).replace("[", "")
    puertosLimpios2 =  str(puertosLimpios).replace("]", "")
    puertosLimpios3 =  str(puertosLimpios2).replace(",", " -")

def process (results):    

    formatParams (results)

    global hostnames3
    global puertosLimpios3

    #Print information
    if args.silent is False:

        print(' ****************************************************************** ')
        print('IP:           {}'.format(results['ip_str']))                       
        print('Hostnames:    {}'.format(hostnames3))
        print('ISP:          {}'.format(results['isp']))
        print('ASN:          {}'.format(results['asn']))
        try:
            print('Location:     {}, {}, {}, {}'.format((results['country_code3']).encode('utf-8'), (results['country_name']).encode('utf-8'), (results['city']).encode('utf-8'), results['postal_code']))
            
        except Exception,e:
            pass
        
        print('Ports:        {}'.format(puertosLimpios3))
        print('Updated:      {}'.format(results.get('last_update')[0:10]))
        print(' ****************************************************************** ')

        for data in results['data']:
            puerto = data['port']

            print('-*- Port:     ' + str(data['port']))
            print('    Protocol: ' + str(data['transport']))
            
            try:
                if str(data['os']) == "None":
                    data['os'] = "N/A"
                else:
                    print('    OS:       ' + str(data['os']))
            
            except Exception,e:
                continue

            try:
                print('    Product:  ' + str(data['product']))
            
            except Exception,e:
                data['product'] = "N/A"
                continue
            
            try:
                print('    Version:  ' + str(data['version']))
            
            except Exception,e:
                data['version'] = "N/A"
                continue                  

        print('\n')


def excelWriter (results):

    formatParams (results)
    global hostnames3
    global puertosLimpios3
    global contador

    fileout_sheet.write(contador, 0, results['ip_str'])
    fileout_sheet.write(contador, 1, hostnames3)

    if str(results['isp']) == " ":
        fileout_sheet.write(contador, 2, 'N/A')
    else:
        fileout_sheet.write(contador, 2, str(results['isp']))

    ubicacion = results['country_code3'] + " " + results['country_name'] + " " + results['city'] + " " + results['postal_code']
    fileout_sheet.write(contador, 3, ubicacion)
    fileout_sheet.write(contador, 4, puertosLimpios3)
    fileout_sheet.write(contador, 5, results.get('last_update')[0:10])

    contador += 1

#os.system('clear')
print(' ****************************************************************** ')
             
try:
    if args.target is not None:
        print('Processing target: ' + args.target) 

        try:
            ipv4 = socket.gethostbyname(args.target)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
        except Exception,e:
            print(' !!!  IP not found: !!! {} '.format(args.target))
            #continue
                                
        try:
            results = api.host(ipv4)
            process(results)

            #Export results to XLS file
            if args.exportXLS is not None:           
                excelWriter(results)  

        except Exception,e:
            print('Warning: {}'.format(e))
            #continue
            sleep(1)

    else:

        print('Processing file: ' + str(args.file)) 
        with open(args.file, 'r') as file:
            for line in file.readlines():   
                line_ip = line.split('\n')[0]
                sleep(.500)
                try:
                    ipv4 = socket.gethostbyname(line_ip)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
                except Exception,e:
                    print(' !!!  IP not found: !!! {} '.format(line_ip))
                    continue
                                        
                try:
                    results = api.host(ipv4)
                    process(results)

                    #Export results to XLS file
                    if args.exportXLS is not None:                

                        excelWriter(results)

                except Exception,e:
                    print('Warning: {}'.format(e))
                    continue
                    sleep(1)               
                                
    if args.exportXLS is not None: 
        print('------ Excel file ' + str(args.exportXLS) + ' has been generated ------' + '\n')

    print('------ The execution has been completed ------' + '\n')

except Exception as e:
    print 'Error: %s' % e
    sys.exit(1)

finally:
    if args.exportXLS is not None:
        fileoutXLS.close()