use strict;
use utf8;
use warnings qw(all);

use Test::More;
use Test::Script::Run;

run_output_matches(
    xpathify => [qw[t/test.html]],
    [
        qq(/html/head[1]/title[1]/text()\ttest 1),
        qq(/html/body[1]/h1[1]/text()\ttest 2),
        qq(/html/body[1]/p[1]/text()\t Lorem ipsum dolor sit amet, consectetur adipiscing elit. ),
        qq(/html/body[1]/p[1]/text()\t Ut sed scelerisque nulla. ),
        qq(//li[\@id='li1'][1]/text()\tVestibulum ullamcorper eleifend justo.),
        qq(/html/body[1]/p[1]/ul[1]/li[2]/text()\tSed id sapien tortor.),
        qq(/html/body[1]/p[1]/ul[1]/li[3]/text()\t Fusce et volutpat mi. ),
        qq(/html/body[1]/p[1]/ul[1]/li[4]/text()\tQuisque ullamcorper mauris lacus.),
        qq(/html/body[1]/p[1]/ul[1]/li[5]/text()\tNunc in erat sit amet nisi vulputate pharetra.),
        qq(/html/body[1]/p[1]/text()\t Nam sit amet massa ac justo lacinia cursus. Et harum quidem rerum facilis est et expedita distinctio. ),
        qq(/html/body[1]/p[2]/text()\t Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? ),
    ],
    [],
    q(xpathify output matches),
);

run_output_matches(
    untemplate => [qw[--html t/bash1839.html t/bash2486.html]],
    [map { chomp; $_ } <DATA>],
    [],
    q(untemplate output matches),
);

done_testing(2);

__DATA__
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="http://creaktive.github.com/HTML-Untemplate/highlight.css" type="text/css">
</head>
<body>
<table summary="">
<tr><td colspan="2"><span class="sep">/</span><span class="tag">html</span><span class="sep">/</span><span class="tag">head</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">title</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="att">text()</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>QDB:&nbsp;Quote&nbsp;#1839</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>QDB:&nbsp;Quote&nbsp;#2486</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="tag">html</span><span class="sep">/</span><span class="tag">body</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">form</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">center</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">table</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">tr</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">td</span><span class="arr">[</span><span class="num">2</span><span class="arr">]</span><span class="sep">/</span><span class="tag">font</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">b</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="att">text()</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>Quote&nbsp;#1839</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>Quote&nbsp;#2486</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="sep">/</span><span class="tag">p</span><span class="arr">[</span><span class="sig">@</span><span class="att">class</span><span class="eql">=</span><span class="val">&#39;quote&#39;</span><span class="arr">]</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">a</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="sig">@</span><span class="att">href</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>?1839</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>?2486</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="sep">/</span><span class="tag">p</span><span class="arr">[</span><span class="sig">@</span><span class="att">class</span><span class="eql">=</span><span class="val">&#39;quote&#39;</span><span class="arr">]</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">a</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="tag">b</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="att">text()</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>#1839</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>#2486</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="sep">/</span><span class="tag">a</span><span class="arr">[</span><span class="sig">@</span><span class="att">class</span><span class="eql">=</span><span class="val">&#39;qa&#39;</span><span class="arr">]</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="sig">@</span><span class="att">href</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>./?le=cc8456a913b26eb7364e4e9a94348d04&amp;rox=1839</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>./?le=cc8456a913b26eb7364e4e9a94348d04&amp;rox=2486</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="sep">/</span><span class="tag">p</span><span class="arr">[</span><span class="sig">@</span><span class="att">class</span><span class="eql">=</span><span class="val">&#39;quote&#39;</span><span class="arr">]</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="att">text()</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>(245)</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>(228)</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="sep">/</span><span class="tag">a</span><span class="arr">[</span><span class="sig">@</span><span class="att">class</span><span class="eql">=</span><span class="val">&#39;qa&#39;</span><span class="arr">]</span><span class="arr">[</span><span class="num">2</span><span class="arr">]</span><span class="sep">/</span><span class="sig">@</span><span class="att">href</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>./?le=cc8456a913b26eb7364e4e9a94348d04&amp;sox=1839</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>./?le=cc8456a913b26eb7364e4e9a94348d04&amp;sox=2486</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="sep">/</span><span class="tag">a</span><span class="arr">[</span><span class="sig">@</span><span class="att">class</span><span class="eql">=</span><span class="val">&#39;qa&#39;</span><span class="arr">]</span><span class="arr">[</span><span class="num">3</span><span class="arr">]</span><span class="sep">/</span><span class="sig">@</span><span class="att">href</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>./?le=cc8456a913b26eb7364e4e9a94348d04&amp;sux=1839</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>./?le=cc8456a913b26eb7364e4e9a94348d04&amp;sux=2486</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="sep">/</span><span class="tag">p</span><span class="arr">[</span><span class="sig">@</span><span class="att">class</span><span class="eql">=</span><span class="val">&#39;qt&#39;</span><span class="arr">]</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="att">text()</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>&lt;maff&gt;&nbsp;who&nbsp;needs&nbsp;showers&nbsp;when&nbsp;you&#39;ve&nbsp;got&nbsp;an&nbsp;assortment&nbsp;of&nbsp;feminine&nbsp;products</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>&lt;R`:#heroin&gt;&nbsp;Is&nbsp;this&nbsp;for&nbsp;recovery&nbsp;or&nbsp;indulgence?</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
<tr><td colspan="2"><span class="sep">/</span><span class="sep">/</span><span class="tag">tr</span><span class="arr">[</span><span class="num">2</span><span class="arr">]</span><span class="sep">/</span><span class="tag">td</span><span class="arr">[</span><span class="sig">@</span><span class="att">class</span><span class="eql">=</span><span class="val">&#39;footertext&#39;</span><span class="arr">]</span><span class="arr">[</span><span class="num">1</span><span class="arr">]</span><span class="sep">/</span><span class="att">text()</span></td></tr>
<tr><td><span class="doc">bash1839.html</span></td><td>0.0070</td></tr>
<tr><td><span class="doc">bash2486.html</span></td><td>0.0166</td></tr>
<tr><td colspan="2" class="spacer"></td></tr>
</table>
</body>
</html>
