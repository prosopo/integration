if [ -f env ]; then
    # Load Environment Variables
    export $(cat env | grep -v '#' | sed 's/\r$//' | sed "s/\"//g" )
fi