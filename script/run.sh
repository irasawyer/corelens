source .env

set -e

SCRIPT_NAME=$1
TARGET=$2
CONFIRMATION_OVERRIDE=$3

if [[ "$TARGET" == "" ]]
    then
        echo "No TARGET specified. Terminating"
        exit 1
fi
echo "Using target: $TARGET"

NETWORK=$(node script/helpers/readNetwork.js $TARGET)
if [[ "$NETWORK" == "" ]]
    then
        echo "No network found for $TARGET environment target in addresses.json. Terminating"
        exit 1
fi
echo "Using network: $NETWORK"

CALLDATA=$(cast calldata "run(string)" $TARGET)

echo "Interactions calldata:"
echo "$CALLDATA"

forge script script/$SCRIPT_NAME.s.sol:$SCRIPT_NAME -s $CALLDATA --rpc-url $NETWORK -vv --legacy --skip test --ffi

# If the confirmation override is set to s or S - then we skip the rest of the script and exit with success
if [[ "$CONFIRMATION_OVERRIDE" == "s" || "$CONFIRMATION_OVERRIDE" == "S" ]]
    then
        echo "Skipping confirmation and broadcast"
        exit 0
fi

if [[ "$CONFIRMATION_OVERRIDE" == "y" || "$CONFIRMATION_OVERRIDE" == "Y" || "$CONFIRMATION_OVERRIDE" == "n" || "$CONFIRMATION_OVERRIDE" == "N" ]]
    then
        CONFIRMATION="$CONFIRMATION_OVERRIDE"
    else
        read -p "Please verify the data and confirm the interactions logs (y/n):" CONFIRMATION
fi

if [[ "$CONFIRMATION" == "s" || "$CONFIRMATION" == "S" ]]
    then
        echo "Skipping confirmation and broadcast"
        exit 0
fi

if [[ "$CONFIRMATION" == "y" || "$CONFIRMATION" == "Y" ]]
    then
        echo "Broadcasting on-chain..."

        # If $NETWORK is "mumbai" change it to "maticMumbai" for catapulta
        if [[ "$NETWORK" == "mumbai" ]]
            then
                NETWORK="maticMumbai"
        fi

        catapulta script script/$SCRIPT_NAME.s.sol --chain $NETWORK -s $CALLDATA --legacy --skip test --ffi --slow --skip-git
    else
        echo "Deployment cancelled. Execution terminated."
        exit 1
fi