#!/bin/bash
#
# Copyright 2020 Marcos Azevedo (aka pylinux) : psylinux[at]gmail.com
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Description: This Script Changes the file extension

function load {
echo -n "Qual o diretorio onde alterar[.] ? "
read dir
if test -z $dir ; then
	dir="."
fi
echo -n "Qual a porcentagem: "
read porcentagem
}

while true; do
	load
	ls $dir > /dev/null 2>&1
	if test $? -ne 0; then
		echo "Diretorio invalido!!!"
		continue
	fi
	echo "Diretorio: $dir"
	echo "Alterar de 100%"
	echo "Para $porcentagem%"
	echo -n "Executar [s/n]? "
	read exe
	if test -z $exe; then
		break
	fi
	if test $exe = "s"; then
		break;
	fi
done

echo "Esse processo pode levar alguns minutos..."
sleep 1
mkdir redimensionados

cd $dir
for i in `ls *.*`; do
	saida=`echo $i | convert -quality 90 -sample $porcentagemx%$porcentagem% $i redimensionados/$i`
	echo "Redimensionando $i para $porcentagem%"
done
