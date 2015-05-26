{#

OPNsense® is Copyright © 2014 – 2015 by Deciso B.V.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

#}
<style>
    .hidden {
        display:none;
    }
</style>
<script type="text/javascript">

    $( document ).ready(function() {

        /**
         * Render pipe grid using searchPipes api
         */
        var gridPipes =$("#grid-pipes").bootgrid({
            ajax: true,
            selection: true,
            multiSelect: true,
            url: '/api/trafficshaper/settings/searchPipes',
            formatters: {
                "commands": function(column, row)
                {
                    return "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.uuid + "\"><span class=\"fa fa-pencil\"></span></button> " +
                            "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.uuid + "\"><span class=\"fa fa-trash-o\"></span></button>";
                }
            }
        });

        /**
         * Link pipe grid command controls (edit/delete)
         */
        gridPipes.on("loaded.rs.jquery.bootgrid", function(){
            // edit item
            gridPipes.find(".command-edit").on("click", function(e)
            {
                var uuid=$(this).data("row-id");
                mapDataToFormUI({'frm_DialogPipe':"/api/trafficshaper/settings/getPipe/"+uuid}).done(function(){
                    // update selectors
                    formatTokenizersUI();
                    $('.selectpicker').selectpicker('refresh');
                    // clear validation errors (if any)
                    clearFormValidation('frm_DialogPipe');
                });

                // show dialog for pipe edit
                $('#DialogPipe').modal();
                // curry uuid to save action
                $("#btn_DialogPipe_save").unbind('click').click(savePipe.bind(undefined, uuid));
            }).end();

            // delete item
            gridPipes.find(".command-delete").on("click", function(e)
            {
                var uuid  = $(this).data("row-id");
                BootstrapDialog.confirm({
                    title: 'Remove',
                    message: 'Remove selected item?',
                    type: BootstrapDialog.TYPE_DANGER,
                    btnCancelLabel: 'Cancel',
                    btnOKLabel: 'Yes',
                    btnOKClass: 'btn-primary',
                    callback: function(result) {
                        if(result) {
                            var url = "/api/trafficshaper/settings/delPipe/" + uuid;
                            ajaxCall(url=url,sendData={},callback=function(data,status){
                                // reload grid after delete
                                $("#grid-pipes").bootgrid("reload");
                            });
                        }
                    }
                });
            }).end();
        });

        /**
         * save form data to end point for existing pipe
         */
        function savePipe(uuid) {
            saveFormToEndpoint(url="/api/trafficshaper/settings/setPipe/"+uuid,
                    formid="frm_DialogPipe", callback_ok=function(){
                        $("#DialogPipe").modal('hide');
                        $("#grid-pipes").bootgrid("reload");
                    });
        }

        /**
         * save form data to end point for new pipe
         */
        function addPipe() {
            saveFormToEndpoint(url="/api/trafficshaper/settings/addPipe/",
                    formid="frm_DialogPipe", callback_ok=function(){
                        $("#DialogPipe").modal('hide');
                        $("#grid-pipes").bootgrid("reload");
                    });
        }

        /**
         * Delete list of uuids on click event
         */
        $("#deletePipes").click(function(){
            BootstrapDialog.confirm({
                title: 'Remove',
                message: 'Remove selected items?',
                type: BootstrapDialog.TYPE_DANGER,
                btnCancelLabel: 'Cancel',
                btnOKLabel: 'Yes',
                btnOKClass: 'btn-primary',
                callback: function(result) {
                    if(result) {
                        var rows =$("#grid-pipes").bootgrid('getSelectedRows');
                        if (rows != undefined){
                            var deferreds = [];
                            $.each(rows, function(key,uuid){
                                deferreds.push(ajaxCall(url="/api/trafficshaper/settings/delPipe/" + uuid, sendData={}));
                            });
                            // refresh after load
                            $.when.apply(null, deferreds).done(function(){
                                $("#grid-pipes").bootgrid("reload");
                            });
                        }
                    }
                }
            });
        });

        /**
         * Add new pipe on click event
         */
        $("#addPipe").click(function(){
            mapDataToFormUI({'frm_DialogPipe':"/api/trafficshaper/settings/getPipe/"}).done(function(){
                // update selectors
                formatTokenizersUI();
                $('.selectpicker').selectpicker('refresh');
                // clear validation errors (if any)
                clearFormValidation('frm_DialogPipe');
            });

            // show dialog for pipe edit
            $('#DialogPipe').modal();
            // curry uuid to save action
            $("#btn_DialogPipe_save").unbind('click').click(addPipe);

        });

    });


</script>

<table id="grid-pipes" class="table table-condensed table-hover table-striped">
    <thead>
        <tr>
            <th data-column-id="number" data-type="number">Number</th>
            <th data-column-id="bandwidth" data-type="number">Bandwidth</th>
            <th data-column-id="bandwidthMetric" data-type="string">BandwidthMetric</th>
            <th data-column-id="description" data-type="string">description</th>
            <th data-column-id="commands" data-formatter="commands" data-sortable="false">Commands</th>
            <th data-column-id="uuid" data-type="string" data-identifier="true"  data-visible="false">ID</th>
        </tr>
    </thead>
    <tbody>
    </tbody>
    <tfoot>
        <tr>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td>
                <button type="button" id="addPipe" class="btn btn-xs btn-default"><span class="fa fa-pencil"></span></button>
                <button type="button" id="deletePipes" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
            </td>
        </tr>
    </tfoot>
</table>


{# include dialogs #}
{{ partial("layout_partials/base_dialog",['fields':formDialogPipe,'id':'DialogPipe','label':'Edit pipe'])}}

