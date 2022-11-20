#!/bin/bash
#
# Description: Install Unix Log Collector
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Create the Installer (Install creator can be downloaded from https://makeself.io)
# ./makeself-2.4.5/makeself.sh --gzip --nox11 --nowait dist install-ulc.run "Unix Log Collector Installer" ./install.sh
#

# Colors
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"

# Check root access
if [[ "$EUID" -ne 0 ]]; then
	echo -e "${CRED}! Sorry, you need to run this as root${CEND}"
	exit 1
fi

architecture=$(arch)

# Check to make sure are are on x86_64
[[ "$architecture" != "aarch64"  ]] && echo "${CRED}! $architecture not supported, cannot be installed. You need aarch64 system.${CEND}" && exit 1

DIR="/var/anlyz/oat/"
BINFILE="oat-pull"
SERVICE="oat.service"
SERVICEPATH="/etc/systemd/system/"

# Check if the Unix Log Collector Service is present
# and stop the service
if systemctl list-units --full -all | grep "$SERVICE" > /dev/null 2>&1; then
  echo -ne "* Stopping OAT Collector Service     [..]\r"
  systemctl stop $SERVICE > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "* Stopping OAT Collector Service     [${CRED}FAIL${CEND}]"
    echo ""
    exit 1
  else
    echo -ne "* Stopping OAT Collector Service     [${CGREEN}OK${CEND}]\r"
    echo -ne "\n"
  fi
fi

# Check if the folder is there
if [ -d "$DIR" ]; then
  # Dir exists; So remove old one and copy new one
  rm -f $DIR/$BINFILE
  echo -ne "* Upgrading OAT Collector            [..]\r"
  cp ./$BINFILE $DIR$BINFILE
  if [ $? -ne 0 ]; then
    echo -e "* Upgrading OAT Collector            [${CRED}FAIL${CEND}]"
    echo " "
    exit 1
  else
    echo -ne "* Upgrading OAT Collector            [${CGREEN}OK${CEND}]\r"
    echo -ne "\n"
  fi

else
  # Dir does not exist; Considering new installation
  echo -ne "* Installing OAT Collector           [..]\r"
  mkdir -p $DIR > /dev/null 2>&1
  cp ./$BINFILE $DIR$BINFILE
  if [ $? -ne 0 ]; then
    echo -e "* Installing OAT Collector           [${CRED}FAIL${CEND}]"
    echo " "
    exit 1
  else
    echo -ne "* Installing OAT Collector           [${CGREEN}OK${CEND}]\r"
    echo -ne "\n"
  fi
  cp ./uninstall.sh $DIR
fi

# Check and see if the service file already existsl
# else copy a new service file
if [ -f "$SERVICEPATH$SERVICE" ]; then
  # exists
  echo -ne "* Restarting OAT Collector service   [..]\r"
  systemctl start $SERVICE > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "* Restarting OAT Collector service   [${CRED}FAIL${CEND}]"
    echo " "
    exit 1
  else
    echo -ne "* Restarting OAT Collector service   [${CGREEN}OK${CEND}]\r"
    echo -ne "\n"
  fi
else
  # new
  cp ./$SERVICE $SERVICEPATH$SERVICE
  echo -ne "* Enabling OAT Collector service     [..]\r"
  systemctl enable $SERVICE > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "* Enabling OAT Collector service     [${CRED}FAIL${CEND}]"
    echo " "
    exit 1
  else
    echo -ne "* Enabling OAT Collector service     [${CGREEN}OK${CEND}]\r"
    echo -ne "\n"
  fi

  echo -ne "* Starting OAT Collector service     [..]\r"
  systemctl start $SERVICE > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "* Starting OAT Collector service     [${CRED}FAIL${CEND}]"
    echo " "
    exit 1
  else
    echo -ne "* Starting OAT Collector service     [${CGREEN}OK${CEND}]\r"
    echo -ne "\n"
  fi
fi

echo " "
echo -e "${CGREEN}* Installation Succeeded. Program is placed in ${DIR}.${CEND}"
echo -e "${CGREEN}* You can uninstall from ${DIR}uninstall.sh.${CEND}"
echo " "
exit
