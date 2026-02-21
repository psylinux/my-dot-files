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
#
# Description: This Script Changes the file extension
#

function load {
    echo -n "Qual o diretorio onde alterar[.] ? "
    read dir
    if test -z $dir ; then
	    dir="."
    fi
    echo -n "Mudar a extensao (sem ponto): "
    read extensao
    echo -n "para a extensao (sem ponto): "
    read nova
}

#le lados
while true; do
	load
	ls $dir > /dev/null 2>&1
	if test $? -ne 0; then
		echo "Diretorio invalido!!!"
		continue
	elif test -z $extensao; then
		echo "Extensao a ser alterada invalida!!!"
		continue
	elif test -z $nova; then
		echo "Nova extensao invalida!!!"
		continue
	fi
	echo "Diretorio: $dir"
	echo "Alterar de $extensao"
	echo "Para $nova"
	echo -n "Executar [s/n]? "
	read exe
	if test -z $exe; then
		break
	fi
	if test $exe = "s"; then
		break;
	fi
done

cd $dir
for i in `ls *.$extensao`; do
	saida=`echo $i | sed -e s/\.$extensao/\.$nova/g`
	echo "Movendo $i para $saida"
	mv $i $saida
done
