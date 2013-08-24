<?php
//0.1
//noname
//12-12-2012

&account=Account ID;string;000000
&testMode=Тестовый режим;list;true,false;false
&clickmap=Карта кликов;list;true,false;true
&tracklinks=Внешние ссылки;list;true,false;true
&async=Асинхронный код;list;true,false;true

 Ставим галку на пункте OnWebPagePrerender в разделе Template Service Events

 2.1. Во вкладке Сайт меняем значение radiobutton Регистрировать посещения на Да

 


// Is stats tracking turned on in the Site Config?
if ($modx->getConfig('track_visitors') != 1) {
    return; 
}


// Read Config Parameters
$account = isset($account) && $account != '000000' ? $account : ''; // Ignore default value
$testMode = isset($testMode) && ($testMode == 'true') ? true: false;
$clickmap = isset($clickmap) && ($clickmap == 'true') ? true: false;
$tracklinks = isset($tracklinks) && ($tracklinks == 'true') ? true: false;
$async = isset($async) && ($async == 'true') ? true: false;


// make sure an account number has been supplied
if(!empty($account)) {

    // Options
    if($clickmap) {
        $clickmapString = "
            yaCounter$account.clickmap(true);";
    }

    if($tracklinks) {
        $tracklinksString = "
            yaCounter$account.trackLinks(true);";
    }

    $options = "$clickmapString$tracklinksString";

    if($async) {

        $script = "
<div style=\"display:none;\"><script type=\"text/javascript\">
(function(w, c) {
    (w[c] = w[c] || []).push(function() {
        try {
            w.yaCounter$account = new Ya.Metrika($account);$options
        } catch(e) { }
    });
})(window, 'yandex_metrika_callbacks');
</script></div>
<script src=\"//mc.yandex.ru/metrika/watch.js\" type=\"text/javascript\" defer=\"defer\"></script>
<noscript><div><img src=\"//mc.yandex.ru/watch/$account\" style=\"position:absolute; left:-9999px;\" alt=\"\" /></div></noscript>";

    } else {

        $script = "
<script src=\"//mc.yandex.ru/metrika/watch.js\" type=\"text/javascript\"></script>
<div style=\"display:none;\"><script type=\"text/javascript\">
try { var yaCounter$account = new Ya.Metrika($account);$options} catch(e) { }
</script></div>
<noscript><div><img src=\"//mc.yandex.ru/watch/$account\" style=\"position:absolute; left:-9999px;\" alt=\"\" /></div></noscript>";
    
    }

    $insert_before = 'body';

} else {

    $script = '<!-- Yandex.Metrika account not supplied -->'; 

}


switch ($modx->Event->name) { 
    
    case "OnWebPagePrerender":

        if ($testMode) {
            $script = '<!-- Yandex.Metrika plugin is in test mode - output would be: '. $script . ' -->'; 
        } else if (isset($_SESSION['mgrValidated'])) {
            $script = '<!-- Logged in to Manager - Yandex.Metrika plugin output surpressed, but would be: '. $script . ' -->';    
        }
                
        // Only track HTML documents, in the front end, which have the "Track" box checked in the Manager
        $yandexize = ($modx->isFrontEnd() && $modx->documentObject['donthit']==0 && $modx->documentObject['contentType']=='text/html');
        
        if ($yandexize) {
            $modx->documentOutput = preg_replace("/(<\/$insert_before>)/i", $script."\n\\1", $modx->documentOutput);            
        }
        
        break;

}