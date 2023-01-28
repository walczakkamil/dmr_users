#!/bin/bash

echo "Cleanup"
rm -rf user*.csv

date=$(date +"%Y-%m-%d-%H-%M")


echo "Get last user database"
curl -o user-${date}.csv https://radioid.net/static/user.csv

echo "Replacing of diacritics"
from="ÄÀÂΑÁÅĂÃĀǍĄԱБԲÇĆČЦԾՉՑΔÐДĎԴÉÈÊËΕΗĒĖĘĚЕЁЭԵԷԸЃФՖΓГĢԳՂՀΙÍÎÏĪĮÌǏИԻЙՋΚЌКĶԿՔΛŁЛĻԼΜМՄÑΝНŅŇՆÖÔΟΩÓÒØŌǑÕОՈՕΠПՊՓΡРŘՌՐΣСŠՍΤТŤԹՏÜÙÛÚǓǕǗǙǛŪУŲŮΒВՎЎՒΞԽŸÝЫՅΖŽŹŻЗԶԺäàâαáåąăãāǎաбբçćčћцծչցδđðђдďդéèêëεηęēėěеёэեէըѓфֆγгģգղհιíîïīįìǐиıիйջκќкķկքλłлļĺľլμмմñνńнņňնöôοωóòøōǒõоոօπпպփρрŕřռրσšśсսτтťթտüùûúǔǖǘǚǜūуųůβвվўւξխÿýыüյζžźżзզժ"
to="AAAAAAAAAAAABBCCCCCCCDDDDDEEEEEEEEEEEEEEEEFFFGGGGGHIIIIIIIIIIJJKKKKKKLLLLLMMMNNNNNNOOOOOOOOOOOOOPPPPRRRRRSSSSTTTTTUUUUUUUUUUUUUVVVWWXXYYYYZZZZZZZaaaaaaaaaaaabbccccccccdddddddeeeeeeeeeeeeeeeefffggggghiiiiiiiiiiijjkkkkkklllllllmmmnnnnnnnooooooooooooopppprrrrrrssssstttttuuuuuuuuuuuuuvvvwwxxyyyyyzzzzzzz"
sed -i "y/$from/$to/" user-${date}.csv
